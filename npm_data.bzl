PACKAGES = [
    {
        "name": "@types/argparse@2.0.2",
        "url": "https://registry.yarnpkg.com/@types/argparse/-/argparse-2.0.2.tgz#4eb7e626975ff2526a08a12db5e6cc303807e657",
        "integrity": "sha512-z5yKiFv9jZLXfjLzbPq2Zv0PboFDBZ2NKNs7kC/+AIfqKYcGqGw2ukL0q0NbgCs/ShTTRx+A0/VR+DLnGhAWtw==",
        "deps": [],
    },
    {
        "name": "@types/node@14.14.7",
        "url": "https://registry.yarnpkg.com/@types/node/-/node-14.14.7.tgz#8ea1e8f8eae2430cf440564b98c6dfce1ec5945d",
        "integrity": "sha512-Zw1vhUSQZYw+7u5dAwNbIA9TuTotpzY/OF7sJM9FqPOF3SPjKnxrjoTktXDZgUjybf4cWVBP7O8wvKdSaGHweg==",
        "deps": [],
    },
    {
        "name": "argparse@2.0.1",
        "url": "https://registry.yarnpkg.com/argparse/-/argparse-2.0.1.tgz#246f50f3ca78a3240f6c997e8a9bd1eac49e4b38",
        "integrity": "sha512-8+9WqebbFzpX9OR+Wa6O29asIogeRMzcGtAINdpMHHyAg10f05aSFVBbcEqGf/PXw1EjAZ+q2/bEBg3DvurK3Q==",
        "deps": [],
    },
    {
        "name": "buffer-from@1.1.1",
        "url": "https://registry.yarnpkg.com/buffer-from/-/buffer-from-1.1.1.tgz#32713bc028f75c02fdb710d7c7bcec1f2c6070ef",
        "integrity": "sha512-MQcXEUbCKtEo7bhqEs6560Hyd4XaovZlO/k9V3hjVUF/zwW7KBVdSK4gIt/bzwS9MbR5qob+F5jusZsb0YQK2A==",
        "deps": [],
    },
    {
        "name": "prettier@2.1.2",
        "url": "https://registry.yarnpkg.com/prettier/-/prettier-2.1.2.tgz#3050700dae2e4c8b67c4c3f666cdb8af405e1ce5",
        "integrity": "sha512-16c7K+x4qVlJg9rEbXl7HEGmQyZlG4R9AgP+oHKRMsMsuk8s+ATStlf1NpDqyBI1HpVyfjLOeMhH2LvuNvV5Vg==",
        "deps": [],
    },
    {
        "name": "source-map-support@0.5.19",
        "url": "https://registry.yarnpkg.com/source-map-support/-/source-map-support-0.5.19.tgz#a98b62f86dcaf4f67399648c085291ab9e8fed61",
        "integrity": "sha512-Wonm7zOCIJzBGQdB+thsPar0kYuCIzYvxZwlBa87yi/Mdjv7Tip2cyVbLj5o0cFPN4EVkuTwb3GDDyUx2DGnGw==",
        "deps": [
            {
                "dep": "buffer-from@1.1.1",
                "name": "buffer-from",
            },
            {
                "dep": "source-map@0.6.1",
                "name": "source-map",
            },
        ],
    },
    {
        "name": "source-map@0.6.1",
        "url": "https://registry.yarnpkg.com/source-map/-/source-map-0.6.1.tgz#74722af32e9614e9c287a8d0bbde48b5e2f1a263",
        "integrity": "sha512-UjgapumWlbMhkBgzT7Ykc5YXUT46F0iKu8SGXq0bcwP5dz/h0Plj6enJqjz1Zbq2l5WaqYnrVbwWOWMyF3F47g==",
        "deps": [],
    },
    {
        "name": "tslib@2.0.3",
        "url": "https://registry.yarnpkg.com/tslib/-/tslib-2.0.3.tgz#8e0741ac45fc0c226e58a17bfc3e64b9bc6ca61c",
        "integrity": "sha512-uZtkfKblCEQtZKBF6EBXVZeQNl82yqtDQdv+eck8u7tdPxjLu2/lp5/uPW+um2tpuxINHWy3GhiccY7QgEaVHQ==",
        "deps": [],
    },
    {
        "name": "typescript@4.0.5",
        "url": "https://registry.yarnpkg.com/typescript/-/typescript-4.0.5.tgz#ae9dddfd1069f1cb5beb3ef3b2170dd7c1332389",
        "integrity": "sha512-ywmr/VrTVCmNTJ6iV2LwIrfG1P+lv6luD8sUJs+2eI9NLGigaN+nUQc13iHqisq7bra9lnmUSYqbJvegraBOPQ==",
        "deps": [],
    },
]

ROOTS = [
    {
        "name": "argparse",
        "dep": "argparse@2.0.1",
    },
    {
        "name": "prettier",
        "dep": "prettier@2.1.2",
    },
    {
        "name": "source-map-support",
        "dep": "source-map-support@0.5.19",
    },
    {
        "name": "tslib",
        "dep": "tslib@2.0.3",
    },
    {
        "name": "typescript",
        "dep": "typescript@4.0.5",
    },
    {
        "name": "@types/argparse",
        "dep": "@types/argparse@2.0.2",
    },
    {
        "name": "@types/node",
        "dep": "@types/node@14.14.7",
    },
]
