"""Async HTTP client with retry and timeout"""
import asyncio
import aiohttp
from aiohttp import ClientTimeout
from tenacity import retry, stop_after_attempt, wait_exponential

timeout = ClientTimeout(total=30, connect=10)


@retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=2, max=10))
async def fetch(session: aiohttp.ClientSession, url: str) -> dict:
    async with session.get(url, timeout=timeout) as resp:
        resp.raise_for_status()
        return await resp.json()


async def main():
    async with aiohttp.ClientSession() as session:
        result = await fetch(session, "https://api.example.com/data")
        print(result)


if __name__ == "__main__":
    asyncio.run(main())
