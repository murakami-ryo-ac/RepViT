FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    libglib2.0-0 \
 && rm -rf /var/lib/apt/lists/*

ARG REPO_URL=https://github.com/murakami-ryo-ac/RepViT.git
ARG REPO_REF=main

WORKDIR /app
RUN git clone --depth 1 --branch ${REPO_REF} ${REPO_URL} RepViT

WORKDIR /app/RepViT/verify_repvit_sam
ENV UV_PROJECT_ENVIRONMENT=/app/RepViT/verify_repvit_sam/.venv
RUN uv sync --frozen --no-dev

ENV REPVIT_SAM_CHECKPOINT=/weights/repvit_sam.pt
VOLUME ["/weights"]

ENTRYPOINT ["uv", "run", "python"]
CMD ["verify.py"]
