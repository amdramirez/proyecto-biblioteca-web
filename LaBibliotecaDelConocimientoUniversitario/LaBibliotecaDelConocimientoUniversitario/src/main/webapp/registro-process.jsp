<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*" %>
<%@ include file="config/conexion.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Registro - Biblioteca Universitaria</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="container">
        <%
            String nombre = request.getParameter("nombre");
            String apellido = request.getParameter("apellido");
            String fechaNacimiento = request.getParameter("fecha_nacimiento");
            String carrera = request.getParameter("carrera");
            String sede = request.getParameter("sede");
            String telefono = request.getParameter("telefono");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            
            Connection conn = null;
            PreparedStatement pstmt = null;
            
            try {
                conn = getConnection();
                
                // Insertar usuario con contraseña
                String sql = "INSERT INTO usuario (usu_nombre, usu_apellido, usu_fecha_naci, usu_edad, fecha_registro, cod_carrera, cod_sede, usu_contraseña) " +
                           "VALUES (?, ?, ?, TIMESTAMPDIFF(YEAR, ?, CURDATE()), CURDATE(), ?, ?, ?)";
                pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
                
                pstmt.setString(1, nombre);
                pstmt.setString(2, apellido);
                pstmt.setDate(3, java.sql.Date.valueOf(fechaNacimiento));
                pstmt.setDate(4, java.sql.Date.valueOf(fechaNacimiento));
                pstmt.setInt(5, Integer.parseInt(carrera));
                pstmt.setInt(6, Integer.parseInt(sede));
                pstmt.setString(7, password);
                
                pstmt.executeUpdate();
                
                // Obtener el ID del usuario insertado
                ResultSet generatedKeys = pstmt.getGeneratedKeys();
                int usuarioId = 0;
                if (generatedKeys.next()) {
                    usuarioId = generatedKeys.getInt(1);
                }
                
                // Insertar teléfono
                sql = "INSERT INTO usuario_telefono (usu_id, id_telefono, num_usuario) VALUES (?, 1, ?)";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, usuarioId);
                pstmt.setLong(2, Long.parseLong(telefono));
                pstmt.executeUpdate();
                
                // Insertar correo
                sql = "INSERT INTO usuario_correo (id_correo, usu_id, correo_usuario) VALUES (6, ?, ?)";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, usuarioId);
                pstmt.setString(2, email);
                pstmt.executeUpdate();
                
                out.println("<div class='success-message'>");
                out.println("<h1>¡Registro Exitoso!</h1>");
                out.println("<p>Tu cuenta ha sido creada correctamente.</p>");
                out.println("<p><strong>Nombre:</strong> " + nombre + " " + apellido + "</p>");
                out.println("<p><strong>Email:</strong> " + email + "</p>");
                out.println("<p><strong>Teléfono:</strong> " + telefono + "</p>");
                out.println("<p><a href='login.html?success=registro' class='btn btn-primary'>Iniciar Sesión</a></p>");
                out.println("</div>");
                
            } catch (Exception e) {
                out.println("<div class='error-message'>");
                out.println("<h1>Error en el Registro</h1>");
                out.println("<p>Ha ocurrido un error: " + e.getMessage() + "</p>");
                out.println("<p><a href='login.html'>Volver a intentar</a></p>");
                out.println("</div>");
                e.printStackTrace();
            } finally {
                try {
                    if (pstmt != null) pstmt.close();
                    if (conn != null) conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        %>
    </div>
</body>
</html>
