
# Performance Characteristics

This script does not perform parallel tree walking (single threaded obvisoulsy).   
but it does use some parallelization for the actual hashing operations.

- **Tree traversal**: Single-threaded via `find`
- **Hash computation**: Limited parallelization via `xargs` (typically spawns multiple `b3sum` processes)
- **I/O bound**: Performance is primarily limited by disk I/O rather than CPU


## Tree Walking: **Single-threaded** =>  **Sequential directory processing**

The script processes directories sequentially using a simple `for` loop:

```bash
for item in "${TOSCAN[@]}"; do
    # Process each directory/file one at a time
done
```

## File Processing: **Limited Parallelization** =>  **Parallel file hashing within directories**

within each directory, it uses `find` + `xargs` which can provide some parallelization:

```bash
find -L "$item" -type f ! -name "$OUTPUT_FILE" -print0 | xargs -0 b3sum
```

The `xargs` command can spawn multiple `b3sum` processes simultaneously to hash files found by `find`. By default, `xargs` may run multiple processes in parallel based on system resources.



# better parallel performance

For better parallel performance, I will be using GNU `parallel` instead of `xargs`

The change is **functionally equivalent** - all existing command-line options and behaviors remain the same.
I hope there will be better performance when processing large numbers of files, especially on multi-core systems.

The GNU `parallel` implementation provides key advantages over `xargs`:

- **Better CPU utilization**: `parallel` automatically detects the number of CPU cores and runs that many jobs simultaneously
- **More efficient job distribution**: Better load balancing across available cores

Additionnally: 

- **Progress indication**: Can show progress information (though not used in this implementation)
- **More control**: Offers extensive options for controlling parallelization behavior
