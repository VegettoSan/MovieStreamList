-- Función para verificar la conexión a internet
function check_internet()
    -- Verifica si la consola está conectada a la red
    return wlan.isconnected()
  end
  
  -- Función para cargar los datos desde la URL
  function load_data(url)
    local http = require("socket.http")
    local ltn12 = require("ltn12")
  
    local response_body = {}
    local res, code, response_headers, status = http.request{
      url = url,
      sink = ltn12.sink.table(response_body)
    }
  
    if code == 200 then
      local data = table.concat(response_body)
      -- Parsear los datos recibidos (esto es solo un ejemplo de parsing simple)
      local parsed_data = {}
      local i = 1
      for line in data:gmatch("(.-)\n") do
        if line:match("#LIST#") then
          parsed_data[i] = {}
        elseif line:match("NAME:") then
          parsed_data[i].NAME = line:sub(6)
        elseif line:match("COVER:") then
          parsed_data[i].COVER = line:sub(7)
        elseif line:match("ARCHIVE:") then
          parsed_data[i].ARCHIVE = line:sub(9)
        elseif line:match("#ENDLIST#") then
          i = i + 1
        end
      end
      return parsed_data
    else
      return nil
    end
  end
  
  -- Función para crear la interfaz de usuario
  function create_ui(data)
    screen.clear()
    -- Implementar código para mostrar la portada y los enlaces
    for i, item in ipairs(data) do
      if item.COVER then
        local cover_img = image.load(item.COVER)
        screen.drawImage(10, 10 + (i-1) * 60, cover_img)
      end
      if item.NAME then
        screen.print(80, 10 + (i-1) * 60, item.NAME)
      end
      -- Agregar más elementos según sea necesario
    end
    screen.flip()
  end
  
  -- Función principal
  function main()
    if not check_internet() then
      -- Mostrar mensaje de error en el centro de la pantalla
      screen.clear()
      screen.print(10, 10, "No hay conexión a Internet. Conéctate y reinicia la aplicación.")
      screen.flip()
      os.sleep(3)
      return
    end
  
    local data = load_data("https://github.com/VegettoSan/MovieStreamList/raw/main/Main.movstm")
    if not data then
      screen.clear()
      screen.print(10, 10, "Error al cargar los datos.")
      screen.flip()
      os.sleep(3)
      return
    end
  
    create_ui(data) -- Pasar los datos a la función para crear la interfaz
  
    -- Bucle principal
    while true do
      buttons.read() -- Leer las pulsaciones de los botones
      if buttons.start then break end -- Salir del bucle si se presiona el botón Start
  
      -- Actualizar la interfaz
      -- Aquí puedes actualizar la interfaz según las acciones del usuario
      screen.flip()
    end
  end
  
  main()
  