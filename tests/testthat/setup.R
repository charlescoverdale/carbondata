# Redirect any cache to a temp directory for all tests so nothing
# is written to the user's home filespace during R CMD check.
options(carbondata.cache_dir = tempfile("carbondata_test_cache_"))
