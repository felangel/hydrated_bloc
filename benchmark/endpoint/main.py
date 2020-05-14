from os import walk
import json
import matplotlib.pyplot as plt


def main():
    print('py started')
    files = listFiles()
    jsons = [readJson(x) for x in files]  # 82 files, 693 res
    print(f'loaded {len(jsons)} jsons')
    rr = parse(jsons)
    print(len(rr))
    plot(rr)


def draw(rr, aes, mode, storage, count):
    ff = [
        aesFilter(aes),
        # sizeFilter(2**2),
        countFilter(count),
        modeFilter(mode),
        storageFilter(storage),
    ]
    data = applyFilters(ff, rr)
    # data = sorted(data, key=lambda r: r['count'])
    data = sorted(data, key=lambda r: r['size'])

    xx = [x['count'] for x in data]
    yy = [x['size'] for x in data]
    zz = [x['intMeanMicroseconds'] for x in data]
    ee = [x['intSDMicroseconds'] for x in data]

    # {count}
    # {'aes' if aes else 'non-aes'}
    label = f"{mode} {storage}"
    # ecolor='b', color='b'
    plt.errorbar(yy, zz, yerr=ee, linestyle='-',
                 marker='.', capsize=3, label=label)


# fig, axs = plt.subplots(nrows=2, ncols=2, constrained_layout=True)
def plot(rr):
    for aes in [True, False]:  # [True, False]
        for mode in ['write']:  # ['read', 'write', 'wake']
            i = 0
            fig = plt.figure()
            for count in [1, 30, 150]:
                i += 1  # [1, 15, 30, 75, 150]
                # plt.subplot(2, 1, 1)
                # plt.plot(x1, y1, 'o-')
                # plt.ylabel('Damped oscillation')
                plt.style.use('ggplot')
                # plt.title(f'One bloc. 1:AES. 2:NO AES')
                plt.subplot(3, 1, i)
                plt.title(f'{count} bloc{"s" if count > 1 else ""},' +
                          f' {"aes" if aes else "no aes"}')
                # plt.legend(loc='lower right')
                for storage in ['single', 'multi', 'hive']:
                    draw(rr, aes, mode, storage, count)
                plt.xlabel('Size, bytes')
                plt.ylabel('Time, μs')
                plt.yscale('log')
                plt.xscale('log')
                plt.legend(loc='lower right')
    plt.show()


def aesFilter(flag):
    return lambda r: r['aes'] == flag


def modeFilter(mode):
    return lambda r: mode in r['mode']


def storageFilter(storage):
    return lambda r: storage in r['storage']


def countFilter(count):
    return lambda r: r['count'] == count


def sizeFilter(size):
    return lambda r: r['size'] == size


def applyFilters(ff, rr):
    for f in ff:
        rr = filter(f, rr)
    return list(rr)


def parse(files):
    rr = []
    for file in files:
        count = file['settings']['blocCount']
        size = file['settings']['stateSize']
        for r in file['results']:
            r['count'] = count
            r['size'] = size
            rr.append(r)
    return rr


def readJson(file):
    with open(file) as fl:
        return json.load(fl)


def listFiles():
    for (dirpath, dirnames, filenames) in walk('.'):
        return [x for x in filenames if x.endswith('.json')]


if __name__ == '__main__':
    main()
