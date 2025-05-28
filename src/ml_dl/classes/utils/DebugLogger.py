import time
import traceback
from functools import wraps
from typing import List, Tuple, Any

from rich.console import Console
from rich.panel import Panel
from rich.table import Table
from rich.text import Text
from rich.theme import Theme


class DebugLogger:
    def __init__(self, use_panel_for_errors: bool = False):
        """
        Initialize the logger with custom themes and optional panel usage for errors.

        :param use_panel_for_errors: Whether to automatically use a panel for error messages.
        :type use_panel_for_errors: bool
        """
        self.console = Console()
        # Define custom theme for log levels
        self.custom_theme = Theme({
            "info": "cyan",
            "warning": "yellow",
            "error": "bold red",
            "success": "green",
            "debug": "dim"
        })
        self.console = Console(theme=self.custom_theme)
        self.use_panel_for_errors = use_panel_for_errors

    def log(self, message: str, level: str = "info", use_panel: bool = False):
        """
        Log a message with a given severity level and optional panel.

        :param message: The message to log.
        :type message: str
        :param level: The severity level ('info', 'warning', 'error', 'success', 'debug').
        :type level: str
        :param use_panel: If True, the message will be displayed inside a panel.
        :type use_panel: bool
        :raises ValueError: If the log level is not valid.
        """
        valid_levels = ["info", "warning", "error", "success", "debug"]

        if level not in valid_levels:
            raise ValueError(f"Invalid log level: {level}. Must be one of {valid_levels}")

        # Automatically use a panel for errors if configured
        if level == "error" and self.use_panel_for_errors:
            use_panel = True

        # Format the message to include the log level in uppercase
        formatted_message = Text(f"[{level.upper()}] {message}", style=level)

        # Print message using a panel or as plain text based on the flag
        if use_panel:
            self.console.print(Panel(formatted_message, title=level.capitalize(), expand=False))
        else:
            self.console.print(formatted_message)

    def info(self, message: str):
        """
        Log an info message.

        :param message: The message to log.
        :type message: str
        """
        self.log(message, level="info")

    def warning(self, message: str):
        """
        Log a warning message.

        :param message: The message to log.
        :type message: str
        """
        self.log(message, level="warning")

    def error(self, message: str, exc_info: bool = True):
        """
        Log an error message.

        :param message: The message to log.
        :type message: str
        :param exc_info: Whether to log an exception instead of traceback.
        :type exc_info: bool
        """
        message = message if not exc_info else f"{message}: {traceback.format_exc()}"
        self.log(message, level="error")

    def success(self, message: str):
        """
        Log a success message.

        :param message: The message to log.
        :type message: str
        """
        self.log(message, level="success")

    def debug(self, message: str):
        """
        Log a debug message.

        :param message: The message to log.
        :type message: str
        """
        self.log(message, level="debug")

    def pretty_print_prompt(self, prompt: str, variables: dict = None):
        """
        Pretty print the LLM prompt in a table format.

        :param prompt: The LLM prompt to display.
        :type prompt: str
        :param variables: A dictionary of variables to display.
        :type variables: dict, optional
        """
        table = Table(title="LLM Prompt", expand=False)
        table.add_column("Section", style="bold cyan", no_wrap=True)
        table.add_column("Content", style="bold white")

        table.add_row("Prompt", prompt)

        if variables:
            for key, value in variables.items():
                table.add_row(f"Variable: {key}", str(value))

        self.console.print(table)

    def pretty_print_list_docs(self, docs: List[Tuple[Any]], additional_score: bool = False):
        """
        Pretty print the retrieved docs in a table format.

        :param docs: The list of docs to display.
        """
        table = Table(title="DOCs retrieved", expand=False)

        if not additional_score:
            table.add_column("Filename", style="bold cyan", no_wrap=True)
            table.add_column("Policy", style="bold white")

            for doc in docs:
                table.add_row(doc[0], str(doc[1]))

        else:
            table.add_column("Filename", style="bold cyan", no_wrap=True)
            table.add_column("Aggregated MMR", style="bold white")
            table.add_column("Policy", style="bold white")

            for doc in docs:
                table.add_row(doc[0], str(doc[1]), str(doc[2]))

        self.console.print(table)

    def pretty_print_answer(self, answer: str, additional_info: dict = None):
        """
        Pretty print the LLM answer in a table format.

        :param answer: The LLM answer to display.
        :type answer: str
        :param additional_info: A dictionary of additional info to display.
        :type additional_info: dict, optional
        """
        table = Table(title="LLM Answer", expand=False)
        table.add_column("Section", style="bold cyan", no_wrap=True)
        table.add_column("Content", style="bold white")

        table.add_row("Answer", answer)

        if additional_info:
            for key, value in additional_info.items():
                table.add_row(f"Info: {key}", str(value))

        self.console.print(table)

    @staticmethod
    def profile(func):
        """
        A static method that acts as a decorator to profile the execution time of a function.

        :param func: The function to profile.
        :return: The wrapped function with execution time profiling.
        """

        @wraps(func)
        def wrapper(*args, **kwargs):
            logger = DebugLogger()  # Create a logger instance for this context
            start_time = time.time()
            logger.debug(f"Starting execution of {func.__name__}...")
            result = func(*args, **kwargs)
            end_time = time.time()
            execution_time = end_time - start_time
            logger.success(f"Execution of {func.__name__} completed in {execution_time:.4f} seconds.")
            return result

        return wrapper
