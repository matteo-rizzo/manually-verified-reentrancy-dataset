from pydantic import BaseModel, Field


class EvaluationResult(BaseModel):
    classification: str = Field(
        ...,
        description="The classification label indicating whether the contract is 'reentrant' or 'safe'."
    )
    explanation: str = Field(
        ...,
        description="A detailed explanation for the classification, citing patterns in the contract as evidence."
    )
