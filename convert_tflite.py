import tensorflow as tf

# Load the Keras model
model = tf.keras.models.load_model('gaze_estimation_mpiigaze.h5',compile = False)

# Convert to TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Save the TFLite model
with open("gaze_estimation_mpiigaze.tflite", "wb") as f:
    f.write(tflite_model)
