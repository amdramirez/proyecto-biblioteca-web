<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*" %>
<%@ include file="config/conexion.jsp" %>
<%
    // Verificar autenticación
    if (session.getAttribute("usuario_id") == null || !"estudiante".equals(session.getAttribute("tipo_usuario"))) {
        response.sendRedirect("login.html");
        return;
    }
    
    int usuarioId = (Integer) session.getAttribute("usuario_id");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel de Usuario - La Biblioteca del Conocimiento Universitario</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <header class="header">
        <div class="container">
            <div class="logo">
                <img src="./img/logo.jpg?height=50&width=50" alt="Logo Universidad">
                <h1>La Biblioteca del Conocimiento Universitario</h1>
            </div>
            
            <!-- Search Bar en Header -->
            <div class="header-search">
                <form method="GET" action="catalogo-libros.jsp" class="search-form">
                    <input type="text" name="busqueda" placeholder="Buscar libros, autores..." class="header-search-input">
                    <button type="submit" class="header-search-btn">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <circle cx="11" cy="11" r="8"></circle>
                            <path d="m21 21-4.35-4.35"></path>
                        </svg>
                    </button>
                </form>
            </div>
            
            <nav class="nav">
                <a href="index.html" class="nav-link">Inicio</a>
                <a href="catalogo-libros.jsp" class="nav-link">Catálogo</a>
                <a href="panel-usuario.jsp" class="nav-link active">Mi Panel</a>
            </nav>
        </div>
    </header>

    <main class="main">
        <div class="container">
            <div class="panel-header">
                <h2>Panel de Usuario</h2>
                <div class="user-info">
                    <div class="user-welcome">
                        <span>Bienvenido, <strong><%= session.getAttribute("usuario_nombre") %> <%= session.getAttribute("usuario_apellido") %></strong></span>
                        <span class="user-type">Estudiante</span>
                    </div>
                    <a href="logout.jsp" class="btn btn-logout">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                            <polyline points="16,17 21,12 16,7"></polyline>
                            <line x1="21" y1="12" x2="9" y2="12"></line>
                        </svg>
                        Cerrar Sesión
                    </a>
                </div>
            </div>

            <div class="panel-grid">
                <!-- Datos Personales -->
                <section class="panel-card">
                    <h3>Datos Personales</h3>
                    <div class="user-details">
                        <div class="detail-item">
                            <strong>ID:</strong> <%= usuarioId %>
                        </div>
                        <div class="detail-item">
                            <strong>Nombre:</strong> <%= session.getAttribute("usuario_nombre") %> <%= session.getAttribute("usuario_apellido") %>
                        </div>
                        <%
                            if (session.getAttribute("usuario_fecha_nacimiento") != null) {
                                java.sql.Date fechaNac = (java.sql.Date) session.getAttribute("usuario_fecha_nacimiento");
                                java.time.LocalDate nacimiento = fechaNac.toLocalDate();
                                int edad = java.time.Period.between(nacimiento, java.time.LocalDate.now()).getYears();
                                out.println("<div class='detail-item'><strong>Edad:</strong> " + edad + " años</div>");
                            }
                        %>
                        <div class="detail-item">
                            <strong>Carrera:</strong> <%= session.getAttribute("usuario_carrera") %>
                        </div>
                        <div class="detail-item">
                            <strong>Sede:</strong> <%= session.getAttribute("usuario_sede") %>
                        </div>
                        <div class="detail-item">
                            <strong>Email:</strong> <%= session.getAttribute("usuario_email") %>
                        </div>
                        <%
                            if (session.getAttribute("usuario_telefono") != null) {
                                out.println("<div class='detail-item'><strong>Teléfono:</strong> " + session.getAttribute("usuario_telefono") + "</div>");
                            }
                        %>
                    </div>
                </section>

                <!-- Reservas Activas -->
                <section class="panel-card">
                    <h3>Reservas Activas</h3>
                    <div class="reservas-list">
                        <%
                            Connection conn = null;
                            PreparedStatement pstmt = null;
                            ResultSet rs = null;
                            
                            try {
                                conn = getConnection();
                                String sql = "SELECT r.cod_reserva, r.fecha_prestamo, r.fecha_devolucion, " +
                                           "l.lib_nombre, l.lib_isbn, CONCAT(a.au_nombre, ' ', a.au_apellido) as autor " +
                                           "FROM reservar r " +
                                           "JOIN libro l ON r.cod_libro = l.cod_libro " +
                                           "JOIN autor a ON l.cod_autor = a.cod_autor " +
                                           "WHERE r.usu_id = ? " +
                                           "ORDER BY r.fecha_prestamo DESC";
                                
                                pstmt = conn.prepareStatement(sql);
                                pstmt.setInt(1, usuarioId);
                                rs = pstmt.executeQuery();
                                
                                boolean hasReservas = false;
                                while (rs.next()) {
                                    hasReservas = true;
                                    out.println("<div class='reserva-item'>");
                                    out.println("<div class='libro-info'>");
                                    out.println("<h4>" + rs.getString("lib_nombre") + "</h4>");
                                    out.println("<p>" + rs.getString("autor") + "</p>");
                                    out.println("<span class='isbn'>ISBN: " + rs.getString("lib_isbn") + "</span>");
                                    out.println("</div>");
                                    out.println("<div class='reserva-dates'>");
                                    out.println("<p><strong>Préstamo:</strong> " + rs.getDate("fecha_prestamo") + "</p>");
                                    out.println("<p><strong>Devolución:</strong> " + rs.getDate("fecha_devolucion") + "</p>");
                                    out.println("<span class='status status-active'>Activa</span>");
                                    out.println("</div>");
                                    out.println("<div class='reserva-actions'>");
                                    out.println("<a href='renovar-reserva.jsp?id=" + rs.getInt("cod_reserva") + "' class='btn btn-small'>Renovar</a>");
                                    out.println("<a href='devolver-libro.jsp?id=" + rs.getInt("cod_reserva") + "' class='btn btn-small btn-secondary'>Devolver</a>");
                                    out.println("</div>");
                                    out.println("</div>");
                                }
                                
                                if (!hasReservas) {
                                    out.println("<div class='no-reservas'>");
                                    out.println("<p>No tienes reservas activas.</p>");
                                    out.println("<a href='catalogo-libros.jsp' class='btn btn-primary'>Explorar Catálogo</a>");
                                    out.println("</div>");
                                }
                                
                            } catch (Exception e) {
                                out.println("<p>Error al cargar reservas: " + e.getMessage() + "</p>");
                            } finally {
                                closeResources(conn, pstmt, rs);
                            }
                        %>
                    </div>
                </section>

                <!-- Historial de Préstamos -->
                <section class="panel-card full-width">
                    <h3>Historial de Préstamos</h3>
                    <div class="table-container">
                        <table class="history-table">
                            <thead>
                                <tr>
                                    <th>Libro</th>
                                    <th>Autor</th>
                                    <th>Fecha Préstamo</th>
                                    <th>Fecha Devolución</th>
                                    <th>Estado</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    try {
                                        conn = getConnection();
                                        String sql = "SELECT ar.aud_fecha_prestamo, ar.aud_fecha_devolucion, " +
                                                   "l.lib_nombre, CONCAT(a.au_nombre, ' ', a.au_apellido) as autor, ar.accion " +
                                                   "FROM auditoria_reserva ar " +
                                                   "JOIN libro l ON ar.aud_id_libro = l.cod_libro " +
                                                   "JOIN autor a ON l.cod_autor = a.cod_autor " +
                                                   "WHERE ar.id_usuario = ? AND ar.accion = 'DELETE' " +
                                                   "ORDER BY ar.fecha_evento DESC LIMIT 10";
                                        
                                        pstmt = conn.prepareStatement(sql);
                                        pstmt.setInt(1, usuarioId);
                                        rs = pstmt.executeQuery();
                                        
                                        boolean hasHistory = false;
                                        while (rs.next()) {
                                            hasHistory = true;
                                            out.println("<tr>");
                                            out.println("<td>" + rs.getString("lib_nombre") + "</td>");
                                            out.println("<td>" + rs.getString("autor") + "</td>");
                                            out.println("<td>" + rs.getDate("aud_fecha_prestamo") + "</td>");
                                            out.println("<td>" + rs.getDate("aud_fecha_devolucion") + "</td>");
                                            out.println("<td><span class='status status-completed'>Devuelto</span></td>");
                                            out.println("</tr>");
                                        }
                                        
                                        if (!hasHistory) {
                                            out.println("<tr><td colspan='5' style='text-align: center;'>No hay historial de préstamos</td></tr>");
                                        }
                                        
                                    } catch (Exception e) {
                                        out.println("<tr><td colspan='5'>Error al cargar historial: " + e.getMessage() + "</td></tr>");
                                    } finally {
                                        closeResources(conn, pstmt, rs);
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                </section>
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
