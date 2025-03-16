from sanic import Sanic, response
from services.service_img import ServiceImg
from services.service_ocr import ServiceOcr
from services.service_diff import ServiceDiff

app = Sanic("LabelVerifyMiddleware")


@app.get("/")
async def home(request):
    return response.json(
        {
            "message": "Status OK.",
        }
    )


@app.post("img/ocr")
async def img_ocr(request):
    try:
        # Extract and parsebase64 data from JSON request.
        image_data_base64 = request.json.get("imageBase64")
        if image_data_base64 is None:
            return response.json(
                {
                    "message": "Image input data is missing from the request body.",
                },
                status=400,
            )

        # Decode the image data.
        image = ServiceImg.decode_base64_image(image_data_base64)

        # Get the OCR scan results.
        ocr_scan_results = ServiceOcr.extract_text(image)

        return response.json(
            {
                "data": ocr_scan_results,
            }
        )

    except Exception as e:
        return response.json(
            {
                "message": str(e),
            },
            status=500,
        )


@app.post("img/diff")
async def img_diff(request):
    try:
        # Extract and parsebase64 data from JSON request.
        image1_data_base64 = request.json.get("image1Base64")
        image2_data_base64 = request.json.get("image1Base64")
        if image1_data_base64 is None or image2_data_base64 is None:
            return response.json(
                {
                    "message": "Image input data is missing from the request body.",
                },
                status=400,
            )

        img1 = ServiceImg.decode_base64_image(image1_data_base64)
        img2 = ServiceImg.decode_base64_image(image2_data_base64)

        imgDiff = ServiceDiff.highlight_image_differences(img1, img2)

        imgDiffBase64Encoded = ServiceImg.encode_image_to_base64(imgDiff)

        return response.json(
            {
                "data": imgDiffBase64Encoded,
            }
        )

    except Exception as e:
        return response.json(
            {
                "message": str(e),
            },
            status=500,
        )


@app.route("/<path:path>")
async def catch_all(request, path):
    return response.json(
        {
            "message": f"Path '{path}' not found.",
        },
        status=404,
    )


@app.listener("before_server_start")
async def on_server_start(app, loop):
    print("Python Runtime Server Success")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=50000)
