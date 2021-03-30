from google.cloud import vision
import os

vision_client = vision.ImageAnnotatorClient()

project_id = os.environ["GCP_PROJECT"]


def detect_text(bucket, filename):
    print("Looking for text in image {}".format(filename))

    image = vision.Image(
        source=vision.ImageSource(gcs_image_uri=f"gs://{bucket}/{filename}")
    )
    text_detection_response = vision_client.text_detection(image=image)
    annotations = text_detection_response.text_annotations
    if len(annotations) > 0:
        text = annotations[0].description
    else:
        text = ""
    print("Extracted text {} from image ({} chars).".format(text, len(text)))


def validate_message(message, param):
    var = message.get(param)
    if not var:
        raise ValueError(
            "{} is not provided. Make sure you have \
                          property {} in the request".format(
                param, param
            )
        )
    return var


def uploaded_image(file, context):
    """Triggered by a change to a Cloud Storage bucket.
    Args:
         event (dict): Event payload.
         context (google.cloud.functions.Context): Metadata for the event.
    """
    bucket = validate_message(file, "bucket")
    name = validate_message(file, "name")

    detect_text(bucket, name)
    print(f"Processing file: {file['name']}.")
