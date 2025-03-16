import numpy as np
import cv2


class ServiceDiff:
    """
    Service implemented for highlighting differences in visual media content.
    """

    @staticmethod
    def highlight_image_differences(img1: np.ndarray, img2: np.ndarray) -> np.ndarray:
        # Ensure both images are the same size
        if img1.shape != img2.shape:
            raise ValueError("Images must be the same size for comparison")

        # Compute absolute difference.
        diff = cv2.absdiff(img1, img2)

        # Convert to grayscale.
        gray = cv2.cvtColor(diff, cv2.COLOR_BGR2GRAY)

        # Apply threshold to detect significant differences.
        _, thresh = cv2.threshold(gray, 30, 255, cv2.THRESH_BINARY)

        # Convert to 3-channel mask for highlighting.
        mask = cv2.cvtColor(thresh, cv2.COLOR_GRAY2BGR)

        # Highlight differences in red.
        highlighted = img1.copy()
        highlighted[np.where(mask == 255)] = [0, 0, 255]

        # Return the generated image.
        return highlighted
