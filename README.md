# image_classification_app

This simple app that uses flutter as frontend and pretrained tensorflow model on flask as backend to try to recognize objects on photos.

## How does it work?

App allows you to add your photo straight from camera or gallery.


![alt text](https://raw.githubusercontent.com/ZbigniewTomanek/image_classification_with_flutter/master/images/add_photo.png)

Then this image is uploaded straight to firebase storage and the link to it is passed to simple REST api working on flask.

![alt text](https://raw.githubusercontent.com/ZbigniewTomanek/image_classification_with_flutter/master/images/working.png)

There a mobilnet cnn network describes image downloaded to a server from google storage and returns a list of labels that got the highest probalities in classification process. To be honest this can still be pretty inaccurate.

From the application you have access to all classfied photo, which are stored on your device even after apps closing.

![alt text](https://raw.githubusercontent.com/ZbigniewTomanek/image_classification_with_flutter/master/images/many.png)

 

By clicking on image icon you can zoom it in like this:
![alt text](https://raw.githubusercontent.com/ZbigniewTomanek/image_classification_with_flutter/master/images/cliff.png)


## How can I run it?

At first you need to generate new firebase project and add it to your project as in [this](https://firebase.google.com/docs/flutter/setup)
 tutorial. Same credentials are needed in firebase_config dict in app.py.
 
Then you need to install this python dependencies:

```
pip install pyrebase
pip install Pillow
pip install flask
pip install tf-nightly
```

and run flask server on your local machine with below command from terminal:
```
flask run --host=0.0.0.0
```


In the last step you need to pass your computer/server ip to the flutter app by modyfing URL constant in service.dart

Rember that the computer and mobile device should be in the same network!

After these steps system should be working.

You can also easly experiment with other models by modyfing classification.py file.

