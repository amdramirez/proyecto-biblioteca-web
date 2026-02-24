<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*" %>
<%@ include file="config/conexion.jsp" %>
<%
    // Verificar autenticación
    if (session.getAttribute("usuario_id") == null || !"estudiante".equals(session.getAttribute("tipo_usuario"))) {
        response.sendRedirect("login.html");
        return;
    }
    
    int usuarioId = (Integer) session.getAttribute("usuario_id");
    String libroIdParam = request.getParameter("libro_id");
    
    if (libroIdParam != null && request.getMethod().equals("POST")) {
        // Procesar reserva
        Connection conn = null;
        CallableStatement cstmt = null;
        
        try {
            conn = getConnection();
            String sql = "{CALL carga_reservar(?, ?)}";
            cstmt = conn.prepareCall(sql);
            cstmt.setInt(1, Integer.parseInt(libroIdParam));
            cstmt.setInt(2, usuarioId);
            
            cstmt.execute();
            
            response.sendRedirect("panel-usuario.jsp?success=reserva");
            return;
            
        } catch (Exception e) {
            request.setAttribute("error", "Error al realizar la reserva: " + e.getMessage());
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
    <title>Reservar Libro - Biblioteca Universitaria</title>
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
                <a href="panel-usuario.jsp" class="nav-link">Mi Panel</a>
                <a href="logout.jsp" class="nav-link">Cerrar Sesión</a>
            </nav>
        </div>
    </header>

    <main class="main">
        <div class="container">
            <div class="reserva-container">
                <h2>Reservar Libro</h2>
                
                <%
                    if (request.getAttribute("error") != null) {
                        out.println("<div class='error-message'>" + request.getAttribute("error") + "</div>");
                    }
                %>
                
                <div class="reserva-content">
                    <%
                        String libroId = request.getParameter("libro_id");
                        if (libroId != null) {
                            Connection conn = null;
                            PreparedStatement pstmt = null;
                            ResultSet rs = null;
                            
                            try {
                                conn = getConnection();
                                String sql = "SELECT * FROM v_librosdisponibles WHERE cod_libro = ?";
                                pstmt = conn.prepareStatement(sql);
                                pstmt.setInt(1, Integer.parseInt(libroId));
                                rs = pstmt.executeQuery();
                                
                                if (rs.next()) {
                                    out.println("<div class='libro-selected'>");
                                    out.println("<div class='libro-image'>");
                                    out.println("<img src='/placeholder.svg?height=200&width=150' alt='" + rs.getString("titulo") + "'>");
                                    out.println("</div>");
                                    out.println("<div class='libro-details'>");
                                    out.println("<h3>" + rs.getString("titulo") + "</h3>");
                                    out.println("<p><strong>Autor:</strong> " + rs.getString("autor") + "</p>");
                                    out.println("<p><strong>ISBN:</strong> " + rs.getString("ISBN") + "</p>");
                                    out.println("<p><strong>Editorial:</strong> " + rs.getString("editorial") + "</p>");
                                    out.println("<p><strong>Año:</strong> " + rs.getInt("ano_publicacion") + "</p>");
                                    out.println("<p><strong>Edición:</strong> " + rs.getInt("edicion") + "</p>");
                                    out.println("<p><strong>Disponibles:</strong> <span class='stock'>" + rs.getInt("cantidad") + " ejemplares</span></p>");
                                    out.println("</div>");
                                    out.println("</div>");
                                    
                                    // Formulario de reserva
                                    out.println("<form method='POST' class='reserva-form'>");
                                    out.println("<input type='hidden' name='libro_id' value='" + libroId + "'>");
                                    
                                    out.println("<div class='form-section'>");
                                    out.println("<h4>Información de la Reserva</h4>");
                                    
                                    out.println("<div class='form-group'>");
                                    out.println("<label>Fecha de Préstamo:</label>");
                                    out.println("<input type='date' value='" + java.time.LocalDate.now() + "' readonly>");
                                    out.println("</div>");
                                    
                                    out.println("<div class='form-group'>");
                                    out.println("<label>Fecha de Devolución:</label>");
                                    out.println("<input type='date' value='" + java.time.LocalDate.now().plusDays(7) + "' readonly>");
                                    out.println("</div>");
                                    
                                    out.println("</div>");
                                    
                                    out.println("<div class='form-section'>");
                                    out.println("<h4>Términos y Condiciones</h4>");
                                    out.println("<div class='terms-box'>");
                                    out.println("<ul>");
                                    out.println("<li>El período de préstamo es de 7 días calendario.</li>");
                                    out.println("<li>Puede renovar el préstamo una vez por 7 días adicionales.</li>");
                                    out.println("<li>Máximo 5 libros reservados simultáneamente.</li>");
                                    out.println("<li>La devolución tardía puede generar restricciones.</li>");
                                    out.println("<li>Debe presentar su identificación al retirar el libro.</li>");
                                    out.println("</ul>");
                                    out.println("</div>");
                                    
                                    out.println("<div class='checkbox-group'>");
                                    out.println("<input type='checkbox' id='accept-terms' required>");
                                    out.println("<label for='accept-terms'>Acepto los términos y condiciones</label>");
                                    out.println("</div>");
                                    out.println("</div>");
                                    
                                    out.println("<div class='form-actions'>");
                                    out.println("<a href='catalogo-libros.jsp' class='btn btn-secondary'>Cancelar</a>");
                                    out.println("<button type='submit' class='btn btn-primary'>Confirmar Reserva</button>");
                                    out.println("</div>");
                                    
                                    out.println("</form>");
                                    
                                } else {
                                    out.println("<p>Libro no encontrado.</p>");
                                }
                                
                            } catch (Exception e) {
                                out.println("<p>Error al cargar información del libro: " + e.getMessage() + "</p>");
                            } finally {
                                closeResources(conn, pstmt, rs);
                            }
                        } else {
                            out.println("<p>No se especificó un libro para reservar.</p>");
                            out.println("<a href='catalogo-libros.jsp' class='btn btn-primary'>Volver al Catálogo</a>");
                        }
                    %>
                </div>
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
