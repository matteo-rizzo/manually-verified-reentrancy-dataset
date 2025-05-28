from typing import Dict, Any


class Document:
    """
    A class representing a document with metadata.
    """

    def __init__(self, text: str, metadata: Dict[str, Any]):
        """
        Initialize a Document object.

        :param text: The textual representation of the document.
        :param metadata: Metadata associated with the document.
        """
        self.text = text
        self.metadata = metadata

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> "Document":
        """
        Creates a Document instance from a dictionary.

        :param data: A dictionary containing 'text' and 'metadata' keys.
        :return: A Document instance.
        """
        return cls(
            text=data.get("text", ""),
            metadata=data.get("metadata", {}),
        )

    def to_dict(self) -> Dict[str, Any]:
        """
        Converts the Document instance into a dictionary.

        :return: A dictionary representation of the Document.
        """
        return {
            "text": self.text,
            "metadata": self.metadata,
        }
