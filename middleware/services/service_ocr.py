from typing import Any, Dict, List
import pytesseract
import numpy as np


class ServiceOcr:
    """
    Optical character recognition service implemented with the Tesseract engine.
    """

    @classmethod
    def extract_text(
        cls,
        image: np.ndarray,
    ) -> List[Dict[str, Any]]:
        """
        Extracts text and bounding box positions as percentages.

        :param image: OpenCV image as a NumPy array.
        :return: A list of dictionaries containing extracted text and bounding box positions.
        """

        results: List[Dict[str, Any]] = []
        height, width, _ = image.shape
        data = pytesseract.image_to_data(
            image,
            output_type=pytesseract.Output.DICT,
        )
        for i in range(len(data["text"])):
            text = data["text"][i].strip()
            if text:
                x, y, w, h = (
                    data["left"][i],
                    data["top"][i],
                    data["width"][i],
                    data["height"][i],
                )
                start_x, start_y = x / width, y / height
                end_x, end_y = (x + w) / width, (y + h) / height
                results.append(
                    {
                        "text": text,
                        "start": {
                            "x": start_x,
                            "y": start_y,
                        },
                        "end": {
                            "x": end_x,
                            "y": end_y,
                        },
                    }
                )
        return results
