extends ColorRect

var terminals: SynapticTerminals
var image: Image
var texture: ImageTexture


""" PUBLIC """


func init(width: int, height: int):
	if image == null:
		image = Image.new()

	image.create(width, height, true, Image.FORMAT_R8)
	texture.create_from_image(image, 0)


func get_texture() -> Texture:
	return texture


""" NOTIFICATIONS """


func _ready():
	texture = ImageTexture.new()
	get_material().set("shader_param/txt", texture)
