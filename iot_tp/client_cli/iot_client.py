import os
import hashlib
import base64
import time
import datetime
import random
import requests
import yaml
import cbor

from sawtooth_signing import create_context
from sawtooth_signing import CryptoFactory
from sawtooth_signing import ParseError
from PIL import Image
from PIL.ExifTags import TAGS, GPSTAGS
from sawtooth_signing.secp256k1 import Secp256k1PrivateKey

from sawtooth_sdk.protobuf.transaction_pb2 import TransactionHeader
from sawtooth_sdk.protobuf.transaction_pb2 import Transaction
from sawtooth_sdk.protobuf.batch_pb2 import BatchList
from sawtooth_sdk.protobuf.batch_pb2 import BatchHeader
from sawtooth_sdk.protobuf.batch_pb2 import Batch
from client_cli.exceptions import IoTException

def _sha512(data):
    return hashlib.sha512(data).hexdigest()

def _get_date():
    current_time = datetime.datetime.utcnow()
    current_time = current_time.strftime("%Y-%m-%d-%H-%M-%S")
    return str(current_time)

def _get_metadata(image_path):
    if os.path.isfile(image_path):
        image = Image.open(image_path)
    else:
        return None

    image_meta = {}
    info = image._getexif()
    #hash the whole efix data, this will be use to identify images.
    meta_hash = _sha512(yaml.dump(info).encode('utf-8'))[24:]
    for tag, value in info.items():
        key = TAGS.get(tag, tag)
        #print (key)
        if key == 'GPSInfo' \
           or key == 'Make' \
           or key == 'Model' \
           or key == 'Software' \
           or key == 'DateTimeOriginal':
            image_meta[key] = str(value)
        elif key == 'DateTime':
            image_meta['ModifyDate'] = str(value)
    image_meta['Hash'] = meta_hash
    print (image_meta)
    return image_meta


class IoTClient:
    def __init__(self, url, keyfile=None):
        self.url = url

        if keyfile is not None:
            try:
                with open(keyfile) as fd:
                    private_key_str = fd.read().strip()
                    fd.close()
            except OSError as err:
                    raise IoTException('Failed to read private key: {}'.format(str(err)))
            try:
                private_key = Secp256k1PrivateKey.from_hex(private_key_str)
            except ParseError as e:
                raise IoTException('Unable to load private key: {}'.format(str(e)))

            self._signer = CryptoFactory(create_context('secp256k1')).new_signer(private_key)

    def send(self, path):
        #get user public, we will use as ID
        device_id = self._signer.get_public_key().as_hex()[:4]
        #get image metadata
        metadata = _get_metadata(path)
        #get timestamp
        timestamp = _get_date()
        if metadata is None:
            return "Unable to open Image"
        return self._send_transaction(device_id, metadata, timestamp)

    def _send_transaction(self, device_id, metadata, timestamp):
        payload = cbor.dumps({
            'device_id' : device_id,
            'metadata'  : metadata,
            'timestamp' :timestamp,
        })
        print ("CBOR")
        print (payload)
        pay = cbor.loads(payload)
        print ("DIC")
        print (pay)
        #return (device_id + metadata + timestamp)
