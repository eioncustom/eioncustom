#!/usr/bin/env python3
"""Read an disk image or block device without modifying it; count nonzero bytes."""
"""This is useful to use prior to attempting data recovery. Data that is corrupted can still appears as nonzero. If you see nothing but nonzero bits, there is absolutely no data."""

import argparse
import os
import sys
import time


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", help="disk image or raw block device to read")
    args = parser.parse_args()

    total = 0
    nonzero = 0
    first_nonzero = None
    started = time.monotonic()
    last_progress = started

    try:
        with open(args.source, "rb", buffering=0) as source:
            source_size = source.seek(0, os.SEEK_END)
            source.seek(0)
            print(f"Reading {args.source} (read-only)", flush=True)
            print(f"Source size: {source_size:,} bytes", flush=True)
            while True:
                data = source.read(8 * 1024 * 1024)
                if not data:
                    break

                count = len(data) - data.count(b"\0")
                if count and first_nonzero is None:
                    first_nonzero = total + len(data) - len(data.lstrip(b"\0"))
                total += len(data)
                nonzero += count

                now = time.monotonic()
                if now - last_progress >= 5:
                    speed = total / (now - started) / (1024 * 1024)
                    print(
                        f"Read {total:,} bytes; "
                        f"remaining {max(source_size - total, 0):,} bytes; "
                        f"nonzero {nonzero:,}; "
                        f"{speed:.1f} MiB/s",
                        file=sys.stderr,
                        flush=True,
                    )
                    last_progress = now
    except OSError as error:
        print(
            f"INCOMPLETE: {error}\n"
            f"Read {total:,} bytes; found {nonzero:,} nonzero bytes. "
            "Unread regions remain unknown.",
            file=sys.stderr,
        )
        return 1
    except KeyboardInterrupt:
        print(
            f"\nINCOMPLETE: interrupted after {total:,} bytes; "
            f"found {nonzero:,} nonzero bytes.",
            file=sys.stderr,
        )
        return 130

    if total == 0:
        print("No bytes read; cannot assess this source.", file=sys.stderr)
        return 1

    print(f"Bytes read:    {total:,}")
    print(f"Bytes remaining: {max(source_size - total, 0):,}")
    print(f"Zero bytes:    {total - nonzero:,}")
    print(f"Nonzero bytes: {nonzero:,} ({nonzero / total:.4%})")
    if first_nonzero is not None:
        print(f"First nonzero byte: {first_nonzero} (0x{first_nonzero:X})")
        print("Nonzero content exists; this does not prove files are recoverable.")
    else:
        print("Every byte read was zero.")
    print(
        "For a ddrescue image, zeros may include holes or unread source regions. "
        "Consult the mapfile before concluding the original disk was zeroed."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
