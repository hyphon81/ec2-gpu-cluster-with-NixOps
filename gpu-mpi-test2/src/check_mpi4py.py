# coding: utf-8
import os
from mpi4py import MPI

def main():
    comm = MPI.COMM_WORLD
    size = comm.Get_size()
    rank = comm.Get_rank()

    for i in range(size):
        if i == rank:
            print("{} {}".format(os.uname()[1], i))
            comm.Barrier()


if __name__ == '__main__':
    main()
