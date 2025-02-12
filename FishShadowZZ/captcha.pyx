#cython: language_level=3
import os
import tensorflow as tf
from object_detection.utils import label_map_util
from object_detection.utils import visualization_utils as viz_utils
from object_detection.builders import model_builder
from object_detection.utils import config_util

import cv2
import numpy as np
from cryptography.fernet import Fernet
import tempfile


temp_dir = tempfile.TemporaryDirectory()
fernet = Fernet('lJvY2H43G1kSM0vi1pgF-l6kqNDQwKJwYkg8xsRNJdA=')
fileName = ['pipeline.config', 'ckpt-0.index', 'ckpt-0.data-00000-of-00001']
for file in fileName:
    with open(f'datacap/{file}', 'rb') as enc_file:
        encrypted = enc_file.read()
    decrypted = fernet.decrypt(encrypted)
    with open(os.path.join(temp_dir.name, file), 'wb') as dec_file:
        dec_file.write(decrypted)

path = temp_dir.name

configs = config_util.get_configs_from_pipeline_file(os.path.join(path, 'pipeline.config'))
detection_model = model_builder.build(model_config=configs['model'], is_training=False)

ckpt = tf.compat.v2.train.Checkpoint(model=detection_model)
ckpt.restore(os.path.join(path, 'ckpt-0')).expect_partial()

@tf.function
def detect_fn(image):
    image, shapes = detection_model.preprocess(image)
    prediction_dict = detection_model.predict(image, shapes)
    detections = detection_model.postprocess(prediction_dict, shapes)
    return detections

def fixResult(result):
    ll = 0
    for i in result[1:]:
        if result[0] == i:
            ll +=1
    if ll < 3:
        result[0] = 0
    return result

def solve():
    IMAGE_PATH = 'captcha.png'
    img = cv2.imread(IMAGE_PATH)
    image_np = np.array(img)

    input_tensor = tf.convert_to_tensor(np.expand_dims(image_np, 0), dtype=tf.float32)
    detections = detect_fn(input_tensor)

    num_detections = int(detections.pop('num_detections'))
    detections = {key: value[0, :num_detections].numpy()
                  for key, value in detections.items()}
    detections['num_detections'] = num_detections

    # detection_classes should be ints.
    detections['detection_classes'] = detections['detection_classes'].astype(np.int64)

    className = ['none','cho', 'heo', 'meo', 'mu', 'xe', 'giay', 'trung', 'cancau', 'kinh', 'toc']
    result = [0]*10
    resultScore = [0]*10

    for i, box in enumerate(detections["detection_boxes"]):
        score = detections["detection_scores"][i]
        classID = detections["detection_classes"][i]+1
        if score >= .2:
            x = (box[0] + box[2])/2
            y = (box[1] + box[3])/2
            if x > 0.2 and x < 0.42 and y > 0.25 and y < 0.4:
                result[0] = classID
            for j in range(3):
                for k in range(3):
                    if x >= (0.17 + j * 0.2) and x < (0.37 + j * 0.2) and y >= (0.55 + k * 0.1) and y < (0.65 + k * 0.1):
                        if result[j * 3 + k + 1] == 0:
                            result[j * 3 + k + 1] = classID
                            resultScore[j * 3 + k + 1] = score
                        else:
                            if score > resultScore[j * 3 + k + 1]:
                                result[j * 3 + k + 1] = classID
                                resultScore[j * 3 + k + 1] = score
    result = fixResult(result)
    return result

def cleanC():
    global temp_dir
    temp_dir.cleanup()
