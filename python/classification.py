from __future__ import absolute_import, division, print_function, unicode_literals
import tensorflow as tf
import tensorflow_hub as hub
from tensorflow.keras import layers
import numpy as np
import PIL.Image as Image

classifier_url ="https://tfhub.dev/google/tf2-preview/mobilenet_v2/classification/2"

labels_path = tf.keras.utils.get_file('ImageNetLabels.txt','https://storage.googleapis.com/download.tensorflow.org/data/ImageNetLabels.txt')
imagenet_labels = np.array(open(labels_path).read().splitlines())

IMAGE_SHAPE = (224, 224)

classifier = tf.keras.Sequential([
    hub.KerasLayer(classifier_url, input_shape=IMAGE_SHAPE+(3,))
])


def classify(image_path, num_of_classes=5):
    img = Image.open(image_path).resize(IMAGE_SHAPE)
    img = np.array(img) / 255.0

    result = classifier.predict(img[np.newaxis, ...])[0]

    indexes = []
    for i in range(num_of_classes):
        index = np.argmax(result, axis=-1)
        indexes.append(index)
        result[index] = -np.inf

    return [imagenet_labels[index] for index in indexes]


if __name__ == '__main__':
    img = tf.keras.utils.get_file('image.jpg', 'https://storage.googleapis.com/download.tensorflow.org/example_images/grace_hopper.jpg')
    print(img)
    print(classify('C:\\Users\\zbigi\\.keras\\datasets\\image.jpg'))





