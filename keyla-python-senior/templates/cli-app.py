"""CLI app template with argparse and logging"""
import argparse
import logging
import sys

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)
logger = logging.getLogger(__name__)


def parse_args():
    parser = argparse.ArgumentParser(description="CLI App")
    parser.add_argument("--verbose", "-v", action="store_true", help="Verbose output")
    parser.add_argument("--config", "-c", type=str, help="Config file path")
    parser.add_argument("action", choices=["run", "test", "status"], help="Action to perform")
    return parser.parse_args()


def main():
    args = parse_args()
    if args.verbose:
        logger.setLevel(logging.DEBUG)

    logger.info(f"Action: {args.action}")
    logger.info(f"Config: {args.config or 'default'}")

    try:
        if args.action == "run":
            logger.info("Running...")
        elif args.action == "test":
            logger.info("Testing...")
        elif args.action == "status":
            logger.info("Status: OK")
    except Exception as e:
        logger.error(f"Failed: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
