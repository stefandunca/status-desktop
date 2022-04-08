import NimQml

#[ Represent a part of an image
    image: path to the image
    x, y, width, height: crop rectangle in image coordinates
]#
QtObject:
    type CroppedImage* = ref object of QObject
        image: string
        x: int
        y: int
        width: int
        height: int

    proc setup(self: CroppedImage) =
        self.QObject.setup

    proc delete*(self: CroppedImage) =
        self.QObject.delete

    proc newLogoImage*(): CroppedImage =
        new(result, delete)
        result.setup

    proc setData(self: CroppedImage, image: string, x: int, y: int, width: int, height: int) {.slot.} =
        self.x = x
        self.y = y
        self.width = width
        self.height = height
