<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*" %>
<%@ include file="config/conexion.jsp" %>
<%
    // Verificar autenticación de bibliotecario
    if (session.getAttribute("usuario_id") == null || !"bibliotecario".equals(session.getAttribute("tipo_usuario"))) {
        response.sendRedirect("login.html");
        return;
    }
    
    int bibliotecarioId = (Integer) session.getAttribute("usuario_id");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel Bibliotecario - La Biblioteca del Conocimiento Universitario</title>
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
                <a href="panel-bibliotecario.jsp" class="nav-link active">Panel Bibliotecario</a>
            </nav>
        </div>
    </header>

    <main class="main">
        <div class="container">
            <div class="panel-header">
                <h2>Panel de Bibliotecario</h2>
                <div class="user-info">
                    <div class="bibliotecario-details">
                        <span><strong><%= session.getAttribute("usuario_nombre") %> <%= session.getAttribute("usuario_apellido") %></strong></span>
                        <span>Sede: <%= session.getAttribute("usuario_sede") %></span>
                        <span>Email: <%= session.getAttribute("usuario_email") %></span>
                        <%
                            if (session.getAttribute("usuario_telefono") != null) {
                                out.println("<span>Tel: " + session.getAttribute("usuario_telefono") + "</span>");
                            }
                        %>
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

            <div class="admin-tabs">
                <button class="tab-btn active" onclick="showTab('reservas')">Gestionar Reservas</button>
                <button class="tab-btn" onclick="showTab('libros')">Gestionar Libros</button>
                <button class="tab-btn" onclick="showTab('inventario')">Inventario</button>
                <button class="tab-btn" onclick="showTab('reportes')">Reportes</button>
            </div>

            <!-- Tab: Gestionar Reservas -->
            <div id="reservas-tab" class="tab-content active">
                <section class="panel-card">
                    <h3>Reservas Activas</h3>
                    <div class="table-container">
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th>ID Reserva</th>
                                    <th>Usuario</th>
                                    <th>Libro</th>
                                    <th>Fecha Préstamo</th>
                                    <th>Fecha Devolución</th>
                                    <th>Estado</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    Connection conn = null;
                                    PreparedStatement pstmt = null;
                                    ResultSet rs = null;
                                    
                                    try {
                                        conn = getConnection();
                                        String sql = "SELECT r.cod_reserva, r.fecha_prestamo, r.fecha_devolucion, " +
                                                   "CONCAT(u.usu_nombre, ' ', u.usu_apellido) as usuario, " +
                                                   "l.lib_nombre, r.usu_id, r.cod_libro " +
                                                   "FROM reservar r " +
                                                   "JOIN usuario u ON r.usu_id = u.usu_id " +
                                                   "JOIN libro l ON r.cod_libro = l.cod_libro " +
                                                   "ORDER BY r.fecha_prestamo DESC";
                                        
                                        pstmt = conn.prepareStatement(sql);
                                        rs = pstmt.executeQuery();
                                        
                                        boolean hasReservas = false;
                                        while (rs.next()) {
                                            hasReservas = true;
                                            out.println("<tr>");
                                            out.println("<td>" + rs.getInt("cod_reserva") + "</td>");
                                            out.println("<td>" + rs.getString("usuario") + "</td>");
                                            out.println("<td>" + rs.getString("lib_nombre") + "</td>");
                                            out.println("<td>" + rs.getDate("fecha_prestamo") + "</td>");
                                            out.println("<td>" + rs.getDate("fecha_devolucion") + "</td>");
                                            out.println("<td><span class='status status-active'>Activa</span></td>");
                                            out.println("<td>");
                                            out.println("<a href='renovar-reserva.jsp?id=" + rs.getInt("cod_reserva") + "' class='btn btn-small'>Renovar</a>");
                                            out.println("<a href='devolver-libro.jsp?id=" + rs.getInt("cod_reserva") + "' class='btn btn-small btn-secondary'>Marcar Devuelto</a>");
                                            out.println("</td>");
                                            out.println("</tr>");
                                        }
                                        
                                        if (!hasReservas) {
                                            out.println("<tr><td colspan='7' style='text-align: center;'>No hay reservas activas</td></tr>");
                                        }
                                        
                                    } catch (Exception e) {
                                        out.println("<tr><td colspan='7'>Error al cargar reservas: " + e.getMessage() + "</td></tr>");
                                    } finally {
                                        closeResources(conn, pstmt, rs);
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                </section>
            </div>

            <!-- Tab: Gestionar Libros -->
            <div id="libros-tab" class="tab-content">
                <section class="panel-card">
                    <div class="section-header">
                        <h3>Gestión de Libros</h3>
                        <a href="agregar-libro.jsp" class="btn btn-primary">Agregar Nuevo Libro</a>
                    </div>
                    
                    <div class="table-container">
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th>Código</th>
                                    <th>Título</th>
                                    <th>Autor</th>
                                    <th>ISBN</th>
                                    <th>Editorial</th>
                                    <th>Stock</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    try {
                                        conn = getConnection();
                                        String sql = "SELECT l.cod_libro, l.lib_nombre, l.lib_isbn, " +
                                                   "CONCAT(a.au_nombre, ' ', a.au_apellido) as autor, " +
                                                   "e.edi_nombre, " +
                                                   "COALESCE(i.cantidad_libros, 0) as stock " +
                                                   "FROM libro l " +
                                                   "JOIN autor a ON l.cod_autor = a.cod_autor " +
                                                   "JOIN editorial e ON l.cod_editorial = e.cod_editorial " +
                                                   "LEFT JOIN inventario i ON l.cod_libro = i.cod_libro " +
                                                   "ORDER BY l.lib_nombre";
                                        
                                        pstmt = conn.prepareStatement(sql);
                                        rs = pstmt.executeQuery();
                                        
                                        while (rs.next()) {
                                            out.println("<tr>");
                                            out.println("<td>" + rs.getInt("cod_libro") + "</td>");
                                            out.println("<td>" + rs.getString("lib_nombre") + "</td>");
                                            out.println("<td>" + rs.getString("autor") + "</td>");
                                            out.println("<td>" + rs.getString("lib_isbn") + "</td>");
                                            out.println("<td>" + rs.getString("edi_nombre") + "</td>");
                                            out.println("<td>" + rs.getInt("stock") + "</td>");
                                            out.println("<td>");
                                            out.println("<a href='editar-libro.jsp?id=" + rs.getInt("cod_libro") + "' class='btn btn-small'>Editar</a>");
                                            out.println("<a href='eliminar-libro.jsp?id=" + rs.getInt("cod_libro") + "' class='btn btn-small btn-danger' onclick='return confirm(\"¿Está seguro?\")'>Eliminar</a>");
                                            out.println("</td>");
                                            out.println("</tr>");
                                        }
                                        
                                    } catch (Exception e) {
                                        out.println("<tr><td colspan='7'>Error al cargar libros: " + e.getMessage() + "</td></tr>");
                                    } finally {
                                        closeResources(conn, pstmt, rs);
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                </section>
            </div>

            <!-- Tab: Inventario -->
            <div id="inventario-tab" class="tab-content">
                <section class="panel-card">
                    <h3>Inventario por Sede</h3>
                    
                    <div class="inventory-grid">
                        <%
                            try {
                                conn = getConnection();
                                
                                // Total de libros
                                String sql = "SELECT COUNT(*) as total FROM inventario";
                                pstmt = conn.prepareStatement(sql);
                                rs = pstmt.executeQuery();
                                int totalLibros = 0;
                                if (rs.next()) {
                                    totalLibros = rs.getInt("total");
                                }
                                
                                out.println("<div class='inventory-card'>");
                                out.println("<h4>Total de Libros</h4>");
                                out.println("<div class='inventory-number'>" + totalLibros + "</div>");
                                out.println("</div>");
                                
                                // Libros prestados
                                sql = "SELECT COUNT(*) as prestados FROM reservar";
                                pstmt = conn.prepareStatement(sql);
                                rs = pstmt.executeQuery();
                                int librosPrestados = 0;
                                if (rs.next()) {
                                    librosPrestados = rs.getInt("prestados");
                                }
                                
                                out.println("<div class='inventory-card'>");
                                out.println("<h4>Libros Prestados</h4>");
                                out.println("<div class='inventory-number'>" + librosPrestados + "</div>");
                                out.println("</div>");
                                
                                // Libros disponibles
                                int librosDisponibles = totalLibros - librosPrestados;
                                out.println("<div class='inventory-card'>");
                                out.println("<h4>Libros Disponibles</h4>");
                                out.println("<div class='inventory-number'>" + librosDisponibles + "</div>");
                                out.println("</div>");
                                
                                // Stock bajo
                                sql = "SELECT COUNT(*) as stock_bajo FROM inventario WHERE cantidad_libros < 5";
                                pstmt = conn.prepareStatement(sql);
                                rs = pstmt.executeQuery();
                                int stockBajo = 0;
                                if (rs.next()) {
                                    stockBajo = rs.getInt("stock_bajo");
                                }
                                
                                out.println("<div class='inventory-card'>");
                                out.println("<h4>Stock Bajo (&lt;5)</h4>");
                                out.println("<div class='inventory-number warning'>" + stockBajo + "</div>");
                                out.println("</div>");
                                
                            } catch (Exception e) {
                                out.println("<p>Error al cargar estadísticas: " + e.getMessage() + "</p>");
                            } finally {
                                closeResources(conn, pstmt, rs);
                            }
                        %>
                    </div>

                    <div class="table-container">
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th>Libro</th>
                                    <th>Autor</th>
                                    <th>Sede</th>
                                    <th>Stock Total</th>
                                    <th>Estado</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    try {
                                        conn = getConnection();
                                        String sql = "SELECT l.lib_nombre, CONCAT(a.au_nombre, ' ', a.au_apellido) as autor, " +
                                                   "s.sed_nombre, COALESCE(i.cantidad_libros, 0) as cantidad " +
                                                   "FROM libro l " +
                                                   "JOIN autor a ON l.cod_autor = a.cod_autor " +
                                                   "JOIN sede s ON l.cod_sede = s.cod_sede " +
                                                   "LEFT JOIN inventario i ON l.cod_libro = i.cod_libro " +
                                                   "ORDER BY cantidad ASC";
                                        
                                        pstmt = conn.prepareStatement(sql);
                                        rs = pstmt.executeQuery();
                                        
                                        while (rs.next()) {
                                            int cantidad = rs.getInt("cantidad");
                                            String statusClass = cantidad < 5 ? "status-warning" : "status-good";
                                            String statusText = cantidad < 5 ? "Stock Bajo" : "Normal";
                                            
                                            out.println("<tr>");
                                            out.println("<td>" + rs.getString("lib_nombre") + "</td>");
                                            out.println("<td>" + rs.getString("autor") + "</td>");
                                            out.println("<td>" + rs.getString("sed_nombre") + "</td>");
                                            out.println("<td>" + cantidad + "</td>");
                                            out.println("<td><span class='status " + statusClass + "'>" + statusText + "</span></td>");
                                            out.println("</tr>");
                                        }
                                        
                                    } catch (Exception e) {
                                        out.println("<tr><td colspan='5'>Error al cargar inventario: " + e.getMessage() + "</td></tr>");
                                    } finally {
                                        closeResources(conn, pstmt, rs);
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                </section>
            </div>

            <!-- Tab: Reportes -->
            <div id="reportes-tab" class="tab-content">
                <section class="panel-card">
                    <h3>Reportes y Estadísticas</h3>
                    <div class="reports-grid">
                        <div class="report-card">
                            <h4>Libros Más Solicitados</h4>
                            <ol class="report-list">
                                <%
                                    try {
                                        conn = getConnection();
                                        String sql = "SELECT l.lib_nombre, COUNT(r.cod_libro) as total_reservas " +
                                                   "FROM reservar r " +
                                                   "JOIN libro l ON r.cod_libro = l.cod_libro " +
                                                   "GROUP BY l.lib_nombre " +
                                                   "ORDER BY total_reservas DESC LIMIT 5";
                                        
                                        pstmt = conn.prepareStatement(sql);
                                        rs = pstmt.executeQuery();
                                        
                                        boolean hasData = false;
                                        while (rs.next()) {
                                            hasData = true;
                                            out.println("<li>" + rs.getString("lib_nombre") + " - " + rs.getInt("total_reservas") + " reservas</li>");
                                        }
                                        
                                        if (!hasData) {
                                            out.println("<li>No hay datos disponibles</li>");
                                        }
                                        
                                    } catch (Exception e) {
                                        out.println("<li>Error al cargar datos</li>");
                                    } finally {
                                        closeResources(conn, pstmt, rs);
                                    }
                                %>
                            </ol>
                        </div>
                        
                        <div class="report-card">
                            <h4>Usuarios Más Activos</h4>
                            <ol class="report-list">
                                <%
                                    try {
                                        conn = getConnection();
                                        String sql = "SELECT CONCAT(u.usu_nombre, ' ', u.usu_apellido) as usuario, COUNT(r.usu_id) as total_prestamos " +
                                                   "FROM reservar r " +
                                                   "JOIN usuario u ON r.usu_id = u.usu_id " +
                                                   "GROUP BY u.usu_id " +
                                                   "ORDER BY total_prestamos DESC LIMIT 5";
                                        
                                        pstmt = conn.prepareStatement(sql);
                                        rs = pstmt.executeQuery();
                                        
                                        boolean hasData = false;
                                        while (rs.next()) {
                                            hasData = true;
                                            out.println("<li>" + rs.getString("usuario") + " - " + rs.getInt("total_prestamos") + " préstamos</li>");
                                        }
                                        
                                        if (!hasData) {
                                            out.println("<li>No hay datos disponibles</li>");
                                        }
                                        
                                    } catch (Exception e) {
                                        out.println("<li>Error al cargar datos</li>");
                                    } finally {
                                        closeResources(conn, pstmt, rs);
                                    }
                                %>
                            </ol>
                        </div>
                        
                        <div class="report-card">
                            <h4>Estadísticas del Mes</h4>
                            <div class="stats-list">
                                <%
                                    try {
                                        conn = getConnection();
                                        
                                        // Total préstamos activos
                                        String sql = "SELECT COUNT(*) as total FROM reservar";
                                        pstmt = conn.prepareStatement(sql);
                                        rs = pstmt.executeQuery();
                                        int totalPrestamos = 0;
                                        if (rs.next()) {
                                            totalPrestamos = rs.getInt("total");
                                        }
                                        
                                        out.println("<div class='stat-item'>");
                                        out.println("<span>Préstamos Activos:</span>");
                                        out.println("<strong>" + totalPrestamos + "</strong>");
                                        out.println("</div>");
                                        
                                        // Nuevos usuarios del mes
                                        sql = "SELECT COUNT(*) as total FROM usuario WHERE MONTH(fecha_registro) = MONTH(CURDATE()) AND YEAR(fecha_registro) = YEAR(CURDATE())";
                                        pstmt = conn.prepareStatement(sql);
                                        rs = pstmt.executeQuery();
                                        int nuevosUsuarios = 0;
                                        if (rs.next()) {
                                            nuevosUsuarios = rs.getInt("total");
                                        }
                                        
                                        out.println("<div class='stat-item'>");
                                        out.println("<span>Nuevos Usuarios:</span>");
                                        out.println("<strong>" + nuevosUsuarios + "</strong>");
                                        out.println("</div>");
                                        
                                        // Total libros
                                        sql = "SELECT COUNT(*) as total FROM libro";
                                        pstmt = conn.prepareStatement(sql);
                                        rs = pstmt.executeQuery();
                                        int totalLibrosDB = 0;
                                        if (rs.next()) {
                                            totalLibrosDB = rs.getInt("total");
                                        }
                                        
                                        out.println("<div class='stat-item'>");
                                        out.println("<span>Total Libros:</span>");
                                        out.println("<strong>" + totalLibrosDB + "</strong>");
                                        out.println("</div>");
                                        
                                    } catch (Exception e) {
                                        out.println("<div class='stat-item'>Error al cargar estadísticas</div>");
                                    } finally {
                                        closeResources(conn, pstmt, rs);
                                    }
                                %>
                            </div>
                        </div>
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

    <script>
        function showTab(tabName) {
            // Ocultar todas las pestañas
            document.querySelectorAll('.tab-content').forEach(tab => {
                tab.classList.remove('active');
            });
            
            // Mostrar la pestaña seleccionada
            document.getElementById(tabName + '-tab').classList.add('active');
            
            // Actualizar botones de pestañas
            document.querySelectorAll('.admin-tabs .tab-btn').forEach(btn => {
                btn.classList.remove('active');
            });
            event.target.classList.add('active');
        }
    </script>
</body>
</html>
