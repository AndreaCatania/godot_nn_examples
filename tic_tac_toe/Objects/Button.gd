extends TextureButton

export(Texture) var tic_res
export(Texture) var tac_res
export(Texture) var void_n_res
export(Texture) var void_h_res

var is_free := true


func set_mark_texture(is_tic):
	if is_tic:
		set_normal_texture(tic_res)
	else:
		set_normal_texture(tac_res)
	is_free = false
	set_hover_texture(null)


func reset():
	is_free = true
	set_normal_texture(void_n_res)
	set_hover_texture(void_h_res)
