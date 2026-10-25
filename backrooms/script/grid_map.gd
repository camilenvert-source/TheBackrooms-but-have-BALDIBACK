extends GridMap

# Haritanın genişliği ve uzunluğu
const MAP_WIDTH = 30
const MAP_HEIGHT = 30

func _ready() -> void:
	# Her seferinde farklı bir harita çıkması için rastgelelik motorunu sıfırla
	randomize()
	generate_backrooms()

func generate_backrooms() -> void:
	# Mevcut tüm eski blokları temizle
	clear()
	
	# Haritayı baştan sona tara
	for x in range(MAP_WIDTH):
		for z in range(MAP_HEIGHT):
			# Kenar duvarları sınır olarak ör (Oyuncu haritadan düşmesin)
			if x == 0 or x == MAP_WIDTH - 1 or z == 0 or z == MAP_HEIGHT - 1:
				set_cell_item(Vector3i(x, 0, z), 0) # 0, MeshLibrary'deki ilk duvarındır
			else:
				# %25 ihtimalle rastgele iç duvarlar yerleştir
				if randf() < 0.25:
					set_cell_item(Vector3i(x, 0, z), 0)
