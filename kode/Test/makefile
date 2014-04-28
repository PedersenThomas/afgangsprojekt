AUTH_CACHE_STORAGE=/dev/shm/auth/

tests: install_dummy_tokens
	@py.test --junitxml results.xml src/*tests.py

install_dummy_tokens:
	install --directory         ${AUTH_CACHE_STORAGE}
	install magic_tokens/*.json ${AUTH_CACHE_STORAGE}