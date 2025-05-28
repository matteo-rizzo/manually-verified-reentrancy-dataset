import os
import time
from typing import List, Optional, Any

from google.genai import types
from llama_index.core.llms import LLM
from llama_index.llms.google_genai import GoogleGenAI
from llama_index.llms.openai import OpenAI

from src.classes.utils.DebugLogger import DebugLogger
from src.classes.xrag.EvaluationResult import EvaluationResult
from src.prompts import ANALYZE_CONTRACT_WITH_CONTEXT_TMPL, ANALYZE_CONTRACT_NO_CONTEXT_TMPL, ANALYZE_REENTRANT_TMPL, \
    ANALYZE_SAFE_TMPL, ANALYZE_GENERAL_TMPL


class LLMHandler:
    def __init__(self):
        self.logger = DebugLogger()
        model_name = os.getenv("MODEL_NAME")
        if not model_name:
            raise ValueError("MODEL_NAME environment variable not set.")
        self.logger.debug(f"Initializing LLMHandler with model '{model_name}'...")

        # Initialize a single LLM instance
        # LlamaIndex's LLM interface is unified, use it for both structured and unstructured calls
        if model_name in ['gemini-2.0-flash', 'gemini-1.5-flash', 'gemini-2.5-flash-preview-05-20']:
            # Ensure you have GOOGLE_API_KEY set in your environment
            self.llm: LLM = GoogleGenAI(
                model_name=model_name,
                temperature=0.0,
                #generation_config=types.GenerateContentConfig(
                #    thinking_config=types.ThinkingConfig(thinking_budget=1024))
            )
        elif model_name in ['gpt-4o', 'gpt-4.1', 'o3-mini', 'o4-mini']:
            # Ensure you have OPENAI_API_KEY set in your environment
            self.llm: LLM = OpenAI(model=model_name, temperature=0.0)
        else:
            raise ValueError(f"Unsupported model name: {model_name}")

    def _retry_request(self, func, *args, max_retries=5, initial_wait=4, **kwargs):
        """
        Handles API rate limits and transient errors by retrying with exponential backoff.

        :param func: The function to retry (e.g., self.llm.complete, self.llm.structured_predict).
        :param args: Positional arguments for the function.
        :param max_retries: Maximum number of retries before failing.
        :param initial_wait: Initial wait time (seconds) before retrying.
        :param kwargs: Keyword arguments for the function.
        :return: The function's result or None if it fails after retries.
        :raises: The last exception if max retries are reached.
        """
        wait_time = initial_wait
        last_exception = None
        for attempt in range(max_retries):
            try:
                return func(*args, **kwargs)
            except Exception as e:
                last_exception = e
                # Check for specific API error types if needed (e.g., RateLimitError)
                self.logger.warning(
                    f"Attempt {attempt + 1}/{max_retries} failed: {e}. "
                    f"Retrying in {wait_time:.2f} seconds..."
                )
                # Optional: Log raw output here if possible, though difficult with structured_predict
                # if isinstance(e, (json.JSONDecodeError, pydantic.ValidationError)):
                #    self.logger.error("Potential malformed JSON output from LLM.")
                #    # Consider logging the prompt that caused the error
                #    # prompt_arg = args[1] if len(args) > 1 else kwargs.get('prompt') # Fragile way to get prompt
                #    # if prompt_arg: self.logger.warning(f"Prompt causing error: {prompt_arg}")

            time.sleep(wait_time)
            wait_time *= 2  # Exponential backoff

        self.logger.error(f"Max retries ({max_retries}) reached. Request failed.")
        if last_exception:
            raise last_exception  # Re-raise the last encountered exception
        return None  # Should not be reached if an exception occurred

    def analyze_contract(
            self,
            contract_source: str,
            similar_contexts: Optional[List[str]] = None
    ) -> Optional[dict[str, Any]]:
        """
        Classifies the security status of an input contract using the configured LLM.

        Uses structured_predict to directly output an EvaluationResult object.

        :param contract_source: Source code of the input contract.
        :param similar_contexts: Optional list of security analyses of similar contracts.
        :return: Json representation of the EvaluationResult object or None if analysis fails after retries.
        """
        self.logger.info("Analyzing input contract for classification.")

        if similar_contexts:
            prompt_template = ANALYZE_CONTRACT_WITH_CONTEXT_TMPL
            template_vars = {
                "contract_source": contract_source,
                "similar_contexts_str": "\n---\n".join(similar_contexts)  # Join contexts nicely
            }
            self.logger.debug("Using prompt template with context.")
        else:
            prompt_template = ANALYZE_CONTRACT_NO_CONTEXT_TMPL
            template_vars = {
                "contract_source": contract_source
            }
            self.logger.debug("Using prompt template without context.")

        try:
            # structured_predict takes the Pydantic class, the prompt template, and kwargs for formatting
            result = self._retry_request(
                self.llm.structured_predict,  # Pass the method itself
                EvaluationResult,  # output_cls (as positional arg for _retry_request)
                prompt=prompt_template,  # Use keyword arg for clarity
                **template_vars  # Variables for the template
            )
            return result.model_dump_json()
        except Exception as e:
            self.logger.error(f"Failed to analyze contract after retries: {e}")
            return None

    def analyze_similar_contract(
            self,
            similar_source_code: str,
            label: str
    ) -> Optional[str]:
        """
        Analyzes a similar contract to generate descriptive text about its
        reentrancy status (why it's safe or how it's vulnerable).

        Uses the standard 'complete' method for free-form text generation.

        :param similar_source_code: Source code of the similar contract.
        :param label: Known label ('safe' or 'reentrant') of the contract.
        :return: Text analysis from the LLM or None if analysis fails after retries.
        """
        self.logger.info(f"Analyzing similar contract (Label: {label}).")
        label_lower = label.lower()

        if label_lower == "reentrant":
            prompt_template = ANALYZE_REENTRANT_TMPL
            template_vars = {"similar_source_code": similar_source_code}
        elif label_lower == "safe":
            prompt_template = ANALYZE_SAFE_TMPL
            template_vars = {"similar_source_code": similar_source_code}
        else:
            self.logger.warning(f"Unexpected contract label: {label}. Defaulting to general analysis.")
            prompt_template = ANALYZE_GENERAL_TMPL
            template_vars = {"similar_source_code": similar_source_code}

        # Format the prompt using the selected template and variables
        formatted_prompt = prompt_template.format(**template_vars)

        try:
            # Use the standard complete method for text generation
            response = self._retry_request(
                self.llm.complete,  # Pass the method itself
                formatted_prompt  # Pass the formatted prompt string
            )
            # .complete returns a CompletionResponse object, get the text
            return response.text + "\n\n --- source code: \n\n" + similar_source_code if response else None
        except Exception as e:
            self.logger.error(f"Failed to analyze similar contract after retries: {e}")
            return None
