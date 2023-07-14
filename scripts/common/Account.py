class Account:
    def __init__(self, name, keyUid, kdfIterations):
        self.name = name
        self.keyUid = keyUid
        self.kdfIterations = kdfIterations

    def __str__(self):
        return f"{self.name} - {self.keyUid}, kdfIterations: {self.kdfIterations}"
