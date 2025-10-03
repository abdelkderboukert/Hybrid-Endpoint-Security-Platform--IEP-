import json
import uuid
from datetime import datetime
from rest_framework.renderers import JSONRenderer

class CustomJSONEncoder(json.JSONEncoder):
    """
    Custom JSON encoder to handle special data types like UUIDs.
    """
    def default(self, o):
        if isinstance(o, uuid.UUID):
            # If the object is a UUID, convert it to a string
            return str(o)
        if isinstance(o, datetime):
            return o.isoformat()
        return super().default(o)

class CustomJSONRenderer(JSONRenderer):
    """
    A custom renderer that uses our special encoder to handle UUIDs.
    """
    encoder_class = CustomJSONEncoder