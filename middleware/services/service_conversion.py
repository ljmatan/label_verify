import base64
import fitz
from PIL import Image
from io import BytesIO


class ServiceConversion:
    """
    Class implementing file conversion methods.
    """

    @classmethod
    def pdf_base64_to_png_base64_list(
        cls,
        pdf_base64: str,
        scale: float = 4.0,
    ) -> list[str]:
        """
        Converts a base64-encoded PDF to a list of base64-encoded PNG images.

        Args:
            pdf_base64 (str): The base64-encoded PDF string.
            scale (float): Scaling factor for higher resolution (default 2.0).

        Returns:
            list[str]: A list of base64-encoded PNG images (one per page).
        """

        # Decode the base64 PDF
        pdf_bytes = base64.b64decode(pdf_base64)

        # Open the PDF from bytes
        pdf_document = fitz.open(stream=pdf_bytes, filetype="pdf")

        png_base64_list = []
        matrix = fitz.Matrix(scale, scale)  # Scale for higher resolution

        for page in pdf_document:
            pixmap = page.get_pixmap(matrix=matrix)  # Render at higher resolution

            # Convert pixmap to PIL image
            image = Image.frombytes(
                "RGB", [pixmap.width, pixmap.height], pixmap.samples
            )

            # Save to a bytes buffer as PNG
            image_buffer = BytesIO()
            image.save(image_buffer, format="PNG")

            # Encode to base64
            png_base64 = base64.b64encode(image_buffer.getvalue()).decode("utf-8")
            png_base64_list.append(png_base64)

        return png_base64_list
