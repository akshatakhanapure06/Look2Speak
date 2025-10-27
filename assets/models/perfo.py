import tensorflow.lite as tflite
import os
import numpy as np
import time

# Path to your TFLite model
model_path = "assets\models\gaze_estimation_model_optimized.tflite"

# Load the TFLite model
interpreter = tflite.Interpreter(model_path=model_path)
interpreter.allocate_tensors()

# Get model details
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# Get model file size
model_size = os.path.getsize(model_path) / (1024 * 1024)  # Convert to MB

# Collect input and output tensor details
input_info = [{"shape": inp["shape"], "dtype": inp["dtype"].__name__} for inp in input_details]
output_info = [{"shape": out["shape"], "dtype": out["dtype"].__name__} for out in output_details]

# Run benchmark for performance estimation
dummy_input = np.random.rand(*input_details[0]["shape"]).astype(input_details[0]["dtype"])

# Measure inference time
num_runs = 100
start_time = time.time()
for _ in range(num_runs):
    interpreter.set_tensor(input_details[0]["index"], dummy_input)
    interpreter.invoke()
end_time = time.time()

# Calculate average inference time per run
avg_inference_time = (end_time - start_time) / num_runs * 1000  # Convert to ms

# Print summary
summary = {
    "Model Size (MB)": round(model_size, 2),
    "Input Details": input_info,
    "Output Details": output_info,
    "Avg Inference Time (ms)": round(avg_inference_time, 2),
}

print(summary)
