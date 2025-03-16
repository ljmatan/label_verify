import base64
import numpy as np
import cv2


class ServiceImg:
    """
    Image data handling methods and properties.
    """

    @staticmethod
    def decode_base64_image(base64_string: str) -> np.ndarray:
        """
        Decodes a base64 string into an OpenCV image.
        """

        image_data = base64.b64decode(base64_string)
        np_arr = np.frombuffer(image_data, np.uint8)
        image = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
        if image is None:
            raise ValueError("Error: Unable to decode base64 image.")
        return image

    @staticmethod
    def encode_image_to_base64(image: np.ndarray) -> str:
        """
        Encodes an OpenCV image (np.ndarray) to a base64 string.
        """
        _, buffer = cv2.imencode(".png", image)
        base64_string = base64.b64encode(buffer).decode("utf-8")
        return base64_string
