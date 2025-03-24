import numpy as np
import cv2
from typing import List, Dict, Tuple


class ServiceDiff:
    """
    Service implemented for highlighting differences in visual media content.
    """

    @classmethod
    def highlight_image_differences(
        cls,
        img1: np.ndarray,
        img2: np.ndarray,
        min_contour_area=50,
    ) -> Tuple[np.ndarray, List[Dict]]:
        """
        Highlights differences between two base64-encoded images by drawing semi-transparent filled bounding boxes
        with a visible border. Filters out small areas based on min_contour_area.
        """

        if img1.shape != img2.shape:
            raise ValueError("Images must have the same dimensions")

        img_height, img_width = img1.shape[:2]

        diff = cv2.absdiff(img1, img2)
        gray_diff = cv2.cvtColor(diff, cv2.COLOR_BGR2GRAY)
        _, thresh = cv2.threshold(gray_diff, 30, 255, cv2.THRESH_BINARY)

        contours, _ = cv2.findContours(
            thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE
        )
        highlighted = img1.copy()
        overlay = highlighted.copy()

        filtered_countours: List[Dict] = []

        for contour in contours:
            if cv2.contourArea(contour) >= min_contour_area:
                # Get bounding box dimensions
                x, y, w, h = cv2.boundingRect(contour)

                # Calculate percentage values relative to image size
                x_percent = x / img_width
                y_percent = y / img_height
                w_percent = w / img_width
                h_percent = h / img_height

                # Draw filled red rectangle with transparency
                cv2.rectangle(overlay, (x, y), (x + w, y + h), (0, 0, 255), -1)

                # Draw a border around the box
                cv2.rectangle(
                    highlighted, (x, y), (x + w, y + h), (0, 0, 0), 1
                )  # Black border

                # Create a JSON object representing the contour's data (including percentages)
                contour_data = {
                    "x": x,
                    "y": y,
                    "width": w,
                    "height": h,
                    "xPercent": x_percent,
                    "yPercent": y_percent,
                    "widthPercent": w_percent,
                    "heightPercent": h_percent,
                }

                # Append the contour data to filtered_contours
                filtered_countours.append(contour_data)

        alpha = 0.3  # Transparency factor
        cv2.addWeighted(overlay, alpha, highlighted, 1 - alpha, 0, highlighted)

        return highlighted, filtered_countours
