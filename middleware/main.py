import sys
from flask import Flask, request, jsonify
from services.service_img import ServiceImg
from services.service_ocr import ServiceOcr
from services.service_diff import ServiceDiff

app = Flask("LabelVerifyMiddleware")


@app.route("/", methods=["GET"])
def home():
    return jsonify({"message": "Status OK."})


@app.route("/img/ocr", methods=["POST"])
def img_ocr():
    try:
        data = request.get_json()
        image_data_base64 = data.get("imageBase64")
        if image_data_base64 is None:
            return (
                jsonify(
                    {
                        "message": "Image input data is missing from the request body.",
                    }
                ),
                400,
            )

        # Decode image and extract OCR text
        image = ServiceImg.decode_base64_image(image_data_base64)
        ocr_scan_results = ServiceOcr.extract_text(image)

        return jsonify(
            {
                "data": ocr_scan_results,
            }
        )

    except Exception as e:
        return (
            jsonify(
                {
                    "message": str(e),
                }
            ),
            500,
        )


@app.route("/img/diff", methods=["POST"])
def img_diff():
    try:
        data = request.get_json()
        image1_data_base64 = data.get("image1Base64")
        image2_data_base64 = data.get("image2Base64")

        if not image1_data_base64 or not image2_data_base64:
            return (
                jsonify(
                    {
                        "message": "Image input data is missing from the request body.",
                    }
                ),
                400,
            )

        img1 = ServiceImg.decode_base64_image(image1_data_base64)
        img2 = ServiceImg.decode_base64_image(image2_data_base64)

        img_diff = ServiceDiff.highlight_image_differences(img1, img2)
        img_diff_base64 = ServiceImg.encode_image_to_base64(img_diff)

        return jsonify(
            {
                "data": img_diff_base64,
            }
        )

    except Exception as e:
        return (
            jsonify(
                {
                    "message": str(e),
                }
            ),
            500,
        )


@app.route("/<path:path>", methods=["GET", "POST"])
def catch_all(path):
    return (
        jsonify(
            {
                "message": f"Path '{path}' not found.",
            }
        ),
        404,
    )


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <server_port>")
        sys.exit(1)
    port_number = sys.argv[1]
    app.run(host="0.0.0.0", port=int(port_number))
