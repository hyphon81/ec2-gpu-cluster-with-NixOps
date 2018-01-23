from distutils.core import setup

setup(
    name='gpu-mpi-test2',
    version='0.0.1',
    description='For testing to use multi gpus with mpi',
    author='hyphon81',
    author_email='zero812n@gmail.com',
    install_requires=[
        'numpy',
        'cupy',
        'chainer',
        'chainermn',
        'mpi4py'
    ],
    dependency_links=[],
    packages=['src'],
    entry_points="""
    [console_scripts]
    check_mpi4py = src.check_mpi4py:main
    train_mnist_with_MPI = src.train_mnist:main
    """,
)
