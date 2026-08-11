import os
import time

import numpy as np
import torch

from repvit_sam import SamPredictor, sam_model_registry

CHECKPOINT = os.environ.get("REPVIT_SAM_CHECKPOINT", "/weights/repvit_sam.pt")

print("torch:", torch.__version__, "device: cpu")

t0 = time.time()
model = sam_model_registry["repvit"](checkpoint=CHECKPOINT)
model.to("cpu")
print(f"model loaded in {time.time() - t0:.2f}s")

# dummy RGB image
image = (np.random.rand(480, 640, 3) * 255).astype(np.uint8)

predictor = SamPredictor(model)

t0 = time.time()
predictor.set_image(image)
print(f"set_image in {time.time() - t0:.2f}s")

point = np.array([[320, 240]])
label = np.array([1])

t0 = time.time()
masks, scores, logits = predictor.predict(
    point_coords=point,
    point_labels=label,
    multimask_output=True,
)
print(f"predict in {time.time() - t0:.2f}s")

print("masks shape:", masks.shape)
print("scores:", scores)

assert masks.shape[1:] == image.shape[:2]
assert np.isfinite(scores).all()

print("OK: repvit_sam runs end-to-end on CPU")
