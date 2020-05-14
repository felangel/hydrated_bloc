from os import walk
import json
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import numpy as np

# plt.style.use('bmh')
# plt.style.use('fivethirtyeight')
plt.style.use('ggplot')


def main():
    print('py started')
    files = listFiles()
    jsons = [readJson(x) for x in files]  # 82 files, 693 res
    print(f'loaded {len(jsons)} jsons')
    rr = parse(jsons)
    print(len(rr))
    plot(rr)


def plot(rr):
    fig = plt.figure()
    # for mode in ['read', 'write', 'wake']:
    for mode in ['wake']:
        for storage in ['single', 'multi', 'hive']:
            # for count in [1, 15, 30, 75, 150]:
            for count in [1, 150]:
                ff = [
                    aesFilter(True),
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

                # 2D
                # plt.errorbar(yy, zz, yerr=ee, fmt='-o', linestyle='-', marker='.')

                # label = ('aes' if storage else 'no-aes') + f', {count} blocs'
                label = f'{count} aes {mode} {storage}'
                plt.errorbar(yy, zz, yerr=ee, linestyle='-',
                             marker='.', capsize=3, label=label)  # ecolor='b', color='b'
                # plt.scatter(xx, yy)

    # leg = ax.legend()
    # for artist, text in zip(leg.legendHandles, leg.get_texts()):
    #     col = artist.get_color()
    #     if isinstance(col, np.ndarray):
    #         col = col[0]
    #     text.set_color(col)

    # plt.xlabel('count')
    plt.xlabel('Size, bytes')
    plt.ylabel('Time, μs')
    plt.yscale('log')
    plt.xscale('log')
    plt.legend(loc='lower right')
    plt.show()

    # 3D
    # fig = plt.figure()
    # ax = fig.gca(projection='3d')
    # ax.scatter(xx, yy, zz, label='bench')
    # ax.legend()
    # plt.show()


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


# (aes, storage, mode, count, size)
def parse(files):
    # return [r for file in files for r in getResults(file)]
    rr = []
    for file in files:
        count = file['settings']['blocCount']
        size = file['settings']['stateSize']
        for r in file['results']:
            # key = (r['aes'], r['storage'], r['mode'], count, size)
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
