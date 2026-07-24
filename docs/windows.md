# Windows Setup

This project runs locally from:

```powershell
D:\Projects\book-ocr-conversion
```

It is focused on book OCR, Markdown extraction, standalone HTML generation, Zotero Markdown child attachments, PDF attachment naming, and conservative cleanup queues.

## Runtime

Use the Windows runner:

```powershell
cd D:\Projects\book-ocr-conversion
.\scripts\run_windows.ps1 -Install worker --dry-run --limit 5
```

The runner creates `.venv`, preferring uv-managed Python 3.11 and falling back to `python -m venv` when uv cannot use its managed interpreter. It installs `requirements-win.txt`, sets `HOME` to `USERPROFILE` when needed, and dispatches to the project scripts.

Common tasks:

```powershell
# Zotero route inspection; no OCR upload work.
.\scripts\run_windows.ps1 worker --dry-run --limit 5

# One Zotero attachment, local Markdown only.
.\scripts\run_windows.ps1 worker --attachment-key EXAMPLEKEY --pages 1-1 --no-upload --force-text

# Standalone PDF folder to HTML via remote PaddleOCR-VL.
.\scripts\run_windows.ps1 html --input-dir .\编程书 --output-dir .\output\html_books --limit-books 1

# One local PDF or URL through the PaddleOCR-VL 1.6 API client.
.\scripts\run_windows.ps1 paddleocr .\编程书\some-book.pdf -o .\output\paddle\some-book

# MinerU queue/report.
.\scripts\run_windows.ps1 mineru --dry-run --limit 5

# Zotero PDF attachment-name audit.
.\scripts\run_windows.ps1 normalize --dry-run --limit 20

# 10-50MB PDF inventory report.
.\scripts\run_windows.ps1 inventory
```

For a local smoke check that does not require Zotero to be running:

```powershell
.\scripts\smoke_windows.ps1
```

Add `-CheckZotero` when Zotero is open and its local API is enabled:

```powershell
.\scripts\smoke_windows.ps1 -CheckZotero
```

## PaddleOCR Boundary

In this repository, `PaddleOCR` means Baidu AI Studio remote async OCR jobs, currently `PaddleOCR-VL-1.6`.

Do not install local `paddlepaddle`, local `paddleocr`, or `ocrmypdf-paddleocr` for this pipeline. The Windows dependency set only needs HTTP/PDF/Markdown helpers:

```powershell
.\.venv\Scripts\python.exe -m pip install -r requirements-win.txt
```

Required `.env` keys for scanned/non-extractable PDFs:

```text
BAIDU_PADDLEOCR_TOKEN=
ZOTERO_API_KEY=
ZOTERO_LIBRARY_ID=
```

Do not print these values in logs or terminal output.

The project-local single-file CLI is:

```powershell
D:\Projects\book-ocr-conversion\paddle.py
```

Examples:

```powershell
python .\paddle.py --self-test
python .\paddle.py .\编程书\some-book.pdf -o .\output\paddle\sample
```

WSL can call the same client through a wrapper if one is installed:

```bash
paddle --self-test
paddle /mnt/d/Projects/book-ocr-conversion/编程书/some-book.pdf -o /mnt/d/Projects/book-ocr-conversion/output/paddle/some-book
```

## MinerU

Current MinerU docs resolve to `/opendatalab/mineru`. The documented CLI supports:

```powershell
mineru -p <input_path> -o <output_path> -m ocr -l ch
```

Optional install inside the venv:

```powershell
uv pip install --python .\.venv\Scripts\python.exe -U "mineru[all]"
```

If you need the native MinerU CLI, force its explicit executable path through `.env`:

```text
MINERU_COMMAND=D:\Projects\book-ocr-conversion\.venv\Scripts\mineru.exe
MINERU_METHOD=ocr
MINERU_LANG=ch
MINERU_BACKEND=
```

If native Windows MinerU dependencies become fragile, use WSL2/Docker for MinerU and keep the Baidu PaddleOCR route remote-only.

## MinerU API CLI

For scanned books and academic papers, prefer the MinerU Precision Extract API with:

- `model_version=vlm`
- `is_ocr=true`
- table and formula recognition enabled
- local upload batches capped at 50 files per request
- each source file within the documented Precision API limits: `<=200MB` and `<=200 pages`
- URL inputs selected automatically: one URL uses `/api/v4/extract/task`, multiple URLs use `/api/v4/extract/task/batch`

Project-local single-file CLI:

```powershell
D:\Projects\book-ocr-conversion\mineru.py
```

Examples:

```powershell
python .\mineru.py --self-test
python .\mineru.py .\编程书 -o .\output\mineru\books
python .\mineru.py .\paper.pdf --page-ranges 1-200 -o .\output\mineru\paper
python .\mineru.py https://cdn-mineru.openxlab.org.cn/demo/example.pdf -o .\output\mineru\single-url
```

Completed tasks download `full_zip_url` archives and extract them under the output directory. The main Markdown file is `full.md`; MinerU JSON artifacts are kept next to it.
