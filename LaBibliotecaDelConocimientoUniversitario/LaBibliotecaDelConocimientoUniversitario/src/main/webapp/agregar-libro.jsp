<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*" %>
<%@ include file="config/conexion.jsp" %>
<%
    // Verificar autenticación de bibliotecario
    if (session.getAttribute("usuario_id") == null || !"bibliotecario".equals(session.getAttribute("tipo_usuario"))) {
        response.sendRedirect("login.html");
        return;
    }
    
    // Procesar formulario si es POST
    if (request.getMethod().equals("POST")) {
        Connection conn = null;
        CallableStatement cstmt = null;
        
        try {
            conn = getConnection();
            String sql = "{CALL carga_libro(?, ?, ?, ?, ?, ?, ?, ?, ?)}";
            cstmt = conn.prepareCall(sql);
            
            cstmt.setString(1, request.getParameter("titulo"));
            cstmt.setInt(2, Integer.parseInt(request.getParameter("ano_publicacion")));
            cstmt.setInt(3, Integer.parseInt(request.getParameter("edicion")));
            cstmt.setString(4, request.getParameter("isbn"));
            cstmt.setInt(5, Integer.parseInt(request.getParameter("sede")));
            cstmt.setInt(6, Integer.parseInt(request.getParameter("editorial")));
            cstmt.setString(7, request.getParameter("autor_nombre"));
            cstmt.setString(8, request.getParameter("autor_apellido"));
            cstmt.setInt(9, Integer.parseInt(request.getParameter("cantidad")));
            
            cstmt.execute();
            
            response.sendRedirect("panel-bibliotecario.jsp?success=libro_agregado");
            return;
            
        } catch (Exception e) {
            request.setAttribute("error", "Error al agregar libro: " + e.getMessage());
        } finally {
            try {
                if (cstmt != null) cstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Agregar Libro - Biblioteca Universitaria</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <header class="header">
        <div class="container">
            <div class="logo">
                <img src="./img/logo.jpg?height=50&width=50" alt="Logo Universidad">
                <h1>Biblioteca Universitaria</h1>
            </div>
            <nav class="nav">
                <a href="catalogo-libros.jsp" class="nav-link">Catálogo</a>
                <a href="panel-bibliotecario.jsp" class="nav-link">Panel Bibliotecario</a>
                <a href="logout.jsp" class="nav-link">Cerrar Sesión</a>
            </nav>
        </div>
    </header>

    <main class="main">
        <div class="container">
            <div class="auth-container">
                <h2>Agregar Nuevo Libro</h2>
                
                <%
                    if (request.getAttribute("error") != null) {
                        out.println("<div class='error-message'>" + request.getAttribute("error") + "</div>");
                    }
                %>
                
                <form method="POST" class="auth-form">
                    <div class="form-row">
                        <div class="form-group">
                            <label for="titulo">Título del Libro:</label>
                            <input type="text" id="titulo" name="titulo" required>
                        </div>
                        <div class="form-group">
                            <label for="isbn">ISBN:</label>
                            <input type="text" id="isbn" name="isbn" required>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="autor_nombre">Nombre del Autor:</label>
                            <input type="text" id="autor_nombre" name="autor_nombre" required>
                        </div>
                        <div class="form-group">
                            <label for="autor_apellido">Apellido del Autor:</label>
                            <input type="text" id="autor_apellido" name="autor_apellido" required>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="editorial">Editorial:</label>
                        <select id="editorial" name="editorial" required>
                            <option value="">Seleccionar editorial...</option>
                            <%
                                Connection conn = null;
                                PreparedStatement pstmt = null;
                                ResultSet rs = null;
                                
                                try {
                                    conn = getConnection();
                                    String sql = "SELECT cod_editorial, edi_nombre FROM editorial ORDER BY edi_nombre";
                                    pstmt = conn.prepareStatement(sql);
                                    rs = pstmt.executeQuery();
                                    
                                    while (rs.next()) {
                                        out.println("<option value='" + rs.getInt("cod_editorial") + "'>" + 
                                                   rs.getString("edi_nombre") + "</option>");
                                    }
                                } catch (Exception e) {
                                    e.printStackTrace();
                                } finally {
                                    closeResources(conn, pstmt, rs);
                                }
                            %>
                        </select>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="ano_publicacion">Año de Publicación:</label>
                            <input type="number" id="ano_publicacion" name="ano_publicacion" min="1000" max="2024" required>
                        </div>
                        <div class="form-group">
                            <label for="edicion">Edición:</label>
                            <input type="number" id="edicion" name="edicion" min="1" required>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="sede">Sede:</label>
                            <select id="sede" name="sede" required>
                                <option value="">Seleccionar sede...</option>
                                <%
                                    try {
                                        conn = getConnection();
                                        String sql = "SELECT cod_sede, sed_nombre FROM sede ORDER BY sed_nombre";
                                        pstmt = conn.prepareStatement(sql);
                                        rs = pstmt.executeQuery();
                                        
                                        while (rs.next()) {
                                            out.println("<option value='" + rs.getInt("cod_sede") + "'>" + 
                                                       rs.getString("sed_nombre") + "</option>");
                                        }
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    } finally {
                                        closeResources(conn, pstmt, rs);
                                    }
                                %>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="cantidad">Cantidad de Ejemplares:</label>
                            <input type="number" id="cantidad" name="cantidad" min="1" required>
                        </div>
                    </div>
                    
                    <div class="form-actions">
                        <a href="panel-bibliotecario.jsp" class="btn btn-secondary">Cancelar</a>
                        <button type="submit" class="btn btn-primary">Agregar Libro</button>
                    </div>
                </form>
            </div>
        </div>
    </main>

    <footer class="footer">
        <div class="container">
            <div class="footer-content">
                <div class="footer-section">
                    <h3>Contacto</h3>
                    <p>Email: biblioteca@universidad.edu</p>
                    <p>Teléfono: +507 123-4567</p>
                </div>
                <div class="footer-section">
                    <h3>Horarios</h3>
                    <p>Lunes a Viernes: 7:00 AM - 9:00 PM</p>
                    <p>Sábados: 8:00 AM - 5:00 PM</p>
                </div>
                <div class="footer-section">
                    <h3>Sedes</h3>
                    <p>Sede Central - Panamá</p>
                    <p>Sede Este - Darién</p>
                    <p>Sede Oeste - Panamá Oeste</p>
                </div>
            </div>
        </div>
    </footer>
</body>
</html>
