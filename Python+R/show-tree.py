import os
from pathlib import Path
import argparse

_space = '    '
_vert = '|   '
_offshoot = '|-- '
_last = '`-- '

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('filename')
    parser.add_argument('-l', action='store_true')
    parser.add_argument('-s', action='store_true')
    parser.add_argument('-hs', action='store_true')
    args = parser.parse_args()
    path = Path(args.filename)

    if path.is_file():
        print("The path must point to a directory!")
        return

    print(path)
    for line in tree(path, do_label = args.l, do_size=args.s, human_size=args.hs):
        print(line)

def get_human_size(size):
    if size < 1024:
        return size, "Bytes"
    size /= 1024
    if size < 1024:
        return size, "Kb"
    size /= 1024
    if size < 1024:
        return size, "Mb"
    size /= 1024
    return size, "Gb"

def get_size(start_path):
    total_size = 0
    for dirpath, dirnames, filenames in os.walk(start_path):
        for f in filenames:
            fp = os.path.join(dirpath, f)
            if not os.path.islink(fp):
                total_size += os.path.getsize(fp)

    return total_size

def tree(dir_path: Path, 
         prefix: str='', 
         do_label: bool=False, 
         do_size: bool=False, 
         human_size: bool=False):
    contents = list(dir_path.iterdir())

    pointers = [_offshoot] * (len(contents) - 1) + [_last]

    for pointer, path in zip(pointers, contents):
        text = path.name
        is_dir = path.is_dir()

        if do_label:
            if is_dir:
                text += " (d)"
            else:
                text += " (f)"

        if do_size:
            if is_dir:
                size = get_size(str(path))
            else:
                size = os.stat(str(path)).st_size

            units = "Bytes"
            if human_size:
                size, units = get_human_size(size)

            text += f" {round(size,2)} {units}"
            
        yield prefix + pointer + text
        if is_dir:
            if pointer == _offshoot:
                extension = _vert
            else:
                extension = _space 
            yield from tree(path, prefix=prefix+extension, do_label=do_label, do_size=do_size, human_size=human_size)

if __name__ == '__main__':
    main()
