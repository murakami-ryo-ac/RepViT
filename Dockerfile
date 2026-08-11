FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
 && rm -rf /var/lib/apt/lists/*

ARG REPO_URL=https://github.com/murakami-ryo-ac/RepViT.git
ARG REPO_REF=a16ddf707f487e761f182498bc67b35db50f1eb5

WORKDIR /app
RUN git init RepViT \
 && cd RepViT \
 && git remote add origin ${REPO_URL} \
 && git fetch --depth 1 origin ${REPO_REF} \
 && git checkout FETCH_HEAD

WORKDIR /app/RepViT/verify_repvit_sam
ENV UV_PROJECT_ENVIRONMENT=/app/RepViT/verify_repvit_sam/.venv
RUN uv sync --frozen --no-dev

FROM python:3.12-slim AS runtime

RUN apt-get update && apt-get install -y --no-install-recommends \
    libglib2.0-0 \
 && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/RepViT/sam /app/RepViT/sam
COPY --from=builder /app/RepViT/verify_repvit_sam /app/RepViT/verify_repvit_sam

WORKDIR /app/RepViT/verify_repvit_sam
ENV PATH="/app/RepViT/verify_repvit_sam/.venv/bin:${PATH}"
ENV REPVIT_SAM_CHECKPOINT=/weights/repvit_sam.pt
VOLUME ["/weights"]

ENTRYPOINT ["python"]
CMD ["verify.py"]
