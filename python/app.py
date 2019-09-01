from flask import Flask, request
import pyrebase
import json
from classification import classify


__firebase_config = {
        "apiKey": " AIzaSyDeUkxRY1rUCrM2p7Z4H4Xpdy7dIx-d_d8 ",
        "authDomain": "image-classification-2c2b3.firebaseapp.com",
        "databaseURL": "image-classification-2c2b3.firebaseio.com",
        "storageBucket": "image-classification-2c2b3.appspot.com"
    }

firebase = pyrebase.initialize_app(__firebase_config)
storage = firebase.storage()

app = Flask(__name__)


@app.route('/classify', methods=['GET', 'POST'])
def classify_photo():
    print(request.args.get('key', ''))
    print(request.form['name'])
    image_name = request.form['name']
    image_path = 'images/'+image_name
    image_url = request.form['url']

    #download photo from storage
    storage.child(image_name).download(image_path)
    labels = classify(image_path)

    data = {'name': image_name, 'url': image_url, 'descriptions': labels}
    return json.dumps(data)
