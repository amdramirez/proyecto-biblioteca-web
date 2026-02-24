<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*" %>
<%@ include file="config/conexion.jsp" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Catálogo de Libros - La Biblioteca del Conocimiento Universitario</title>
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
                    <input type="text" name="busqueda" placeholder="Buscar libros, autores..." class="header-search-input" 
                           value="<%= request.getParameter("busqueda") != null ? request.getParameter("busqueda") : "" %>">
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
                <a href="catalogo-libros.jsp" class="nav-link active">Catálogo</a>
                <%
                    if (session.getAttribute("usuario_id") != null) {
                        String tipoUsuario = (String) session.getAttribute("tipo_usuario");
                        if ("bibliotecario".equals(tipoUsuario)) {
                            out.println("<a href='panel-bibliotecario.jsp' class='nav-link'>Panel Bibliotecario</a>");
                        } else {
                            out.println("<a href='panel-usuario.jsp' class='nav-link'>Mi Panel</a>");
                        }
                        out.println("<a href='logout.jsp' class='nav-link'>Cerrar Sesión</a>");
                    } else {
                        out.println("<a href='login.html' class='nav-link'>Login</a>");
                    }
                %>
            </nav>
        </div>
    </header>

    <main class="main">
        <div class="container">
            <section class="hero">
                <h2>Catálogo de Libros Disponibles</h2>
                <p>Explora nuestra colección de recursos bibliográficos</p>
            </section>

            <section class="filters">
                <form method="GET" action="catalogo-libros.jsp">
                    <div class="filter-group">
                        <label for="sede-filter">Sede:</label>
                        <select id="sede-filter" name="sede" class="filter-select">
                            <option value="">Todas las sedes</option>
                            <%
                                Connection conn = null;
                                PreparedStatement pstmt = null;
                                ResultSet rs = null;
                                
                                try {
                                    conn = getConnection();
                                    String sql = "SELECT cod_sede, sed_nombre FROM sede ORDER BY sed_nombre";
                                    pstmt = conn.prepareStatement(sql);
                                    rs = pstmt.executeQuery();
                                    
                                    String sedeSelected = request.getParameter("sede");
                                    
                                    while (rs.next()) {
                                        String selected = String.valueOf(rs.getInt("cod_sede")).equals(sedeSelected) ? "selected" : "";
                                        out.println("<option value='" + rs.getInt("cod_sede") + "' " + selected + ">" + 
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

                    <div class="filter-group">
                        <label for="autor-filter">Autor:</label>
                        <select id="autor-filter" name="autor" class="filter-select">
                            <option value="">Todos los autores</option>
                            <%
                                try {
                                    conn = getConnection();
                                    String sql = "SELECT cod_autor, CONCAT(au_nombre, ' ', au_apellido) as nombre_completo FROM autor ORDER BY au_nombre";
                                    pstmt = conn.prepareStatement(sql);
                                    rs = pstmt.executeQuery();
                                    
                                    String autorSelected = request.getParameter("autor");
                                    
                                    while (rs.next()) {
                                        String selected = String.valueOf(rs.getInt("cod_autor")).equals(autorSelected) ? "selected" : "";
                                        out.println("<option value='" + rs.getInt("cod_autor") + "' " + selected + ">" + 
                                                   rs.getString("nombre_completo") + "</option>");
                                    }
                                } catch (Exception e) {
                                    e.printStackTrace();
                                } finally {
                                    closeResources(conn, pstmt, rs);
                                }
                            %>
                        </select>
                    </div>

                    <div class="search-group">
                        <input type="text" name="busqueda" placeholder="Buscar libros..." class="search-input" 
                               value="<%= request.getParameter("busqueda") != null ? request.getParameter("busqueda") : "" %>">
                        <button type="submit" class="search-btn">Buscar</button>
                    </div>
                </form>
            </section>

            <section class="books-grid">
                <%
                    try {
                        conn = getConnection();
                        
                        // Construir consulta dinámica
                        StringBuilder sqlBuilder = new StringBuilder();
                        sqlBuilder.append("SELECT l.*, a.au_nombre, a.au_apellido, s.sed_nombre, e.edi_nombre, l.url_portada, ");
                        sqlBuilder.append("i.cantidad_libros as cantidad ");
                        sqlBuilder.append("FROM libro l ");
                        sqlBuilder.append("JOIN autor a ON l.cod_autor = a.cod_autor ");
                        sqlBuilder.append("JOIN sede s ON l.cod_sede = s.cod_sede ");
                        sqlBuilder.append("JOIN editorial e ON l.cod_editorial = e.cod_editorial ");
                        sqlBuilder.append("LEFT JOIN inventario i ON l.cod_libro = i.cod_libro ");
                        sqlBuilder.append("WHERE i.cantidad_libros > 0 ");
                        
                        String sedeParam = request.getParameter("sede");
                        String autorParam = request.getParameter("autor");
                        String busquedaParam = request.getParameter("busqueda");
                        
                        if (sedeParam != null && !sedeParam.isEmpty()) {
                            sqlBuilder.append("AND l.cod_sede = ? ");
                        }
                        
                        if (autorParam != null && !autorParam.isEmpty()) {
                            sqlBuilder.append("AND l.cod_autor = ? ");
                        }
                        
                        if (busquedaParam != null && !busquedaParam.isEmpty()) {
                            sqlBuilder.append("AND (l.lib_nombre LIKE ? OR CONCAT(a.au_nombre, ' ', a.au_apellido) LIKE ?) ");
                        }
                        
                        sqlBuilder.append("ORDER BY l.lib_nombre");
                        
                        pstmt = conn.prepareStatement(sqlBuilder.toString());
                        
                        int paramIndex = 1;
                        if (sedeParam != null && !sedeParam.isEmpty()) {
                            pstmt.setInt(paramIndex++, Integer.parseInt(sedeParam));
                        }
                        if (autorParam != null && !autorParam.isEmpty()) {
                            pstmt.setInt(paramIndex++, Integer.parseInt(autorParam));
                        }
                        if (busquedaParam != null && !busquedaParam.isEmpty()) {
                            pstmt.setString(paramIndex++, "%" + busquedaParam + "%");
                            pstmt.setString(paramIndex++, "%" + busquedaParam + "%");
                        }
                        
                        rs = pstmt.executeQuery();
                        
                        boolean hasResults = false;
                        while (rs.next()) {
                            hasResults = true;
                            String urlPortada = rs.getString("url_portada");
                            if (urlPortada == null || urlPortada.trim().isEmpty()) {
                                urlPortada = "/placeholder.svg?height=200&width=150";
                            }
                            
                            out.println("<div class='book-card'>");
                            out.println("<img src='" + urlPortada + "' alt='" + rs.getString("lib_nombre") + "' onerror=\"this.src='/placeholder.svg?height=200&width=150'\">");
                            out.println("<div class='book-info'>");
                            out.println("<h4>" + rs.getString("lib_nombre") + "</h4>");
                            out.println("<p>" + rs.getString("au_nombre") + " " + rs.getString("au_apellido") + "</p>");
                            out.println("<div class='book-meta'>");
                            out.println("<span>ISBN: " + rs.getString("lib_isbn") + "</span>");
                            out.println("<span class='stock'>" + rs.getInt("cantidad") + " disponibles</span>");
                            out.println("<span>Sede: " + rs.getString("sed_nombre") + "</span>");
                            out.println("<span>Editorial: " + rs.getString("edi_nombre") + "</span>");
                            out.println("</div>");
                            
                            if (session.getAttribute("usuario_id") != null) {
                                out.println("<a href='detalle-libro.jsp?id=" + rs.getInt("cod_libro") + "' class='btn btn-outline'>Ver Detalle</a>");
                            } else {
                                out.println("<a href='login.html' class='btn btn-outline'>Iniciar Sesión para Reservar</a>");
                            }
                            
                            out.println("</div>");
                            out.println("</div>");
                        }
                        
                        if (!hasResults) {
                            out.println("<div class='no-results'>");
                            out.println("<h3>No se encontraron libros</h3>");
                            out.println("<p>Intenta con otros filtros de búsqueda.</p>");
                            out.println("</div>");
                        }
                        
                    } catch (Exception e) {
                        out.println("<p>Error al cargar los libros: " + e.getMessage() + "</p>");
                        e.printStackTrace();
                    } finally {
                        closeResources(conn, pstmt, rs);
                    }
                %>
            </section>
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
