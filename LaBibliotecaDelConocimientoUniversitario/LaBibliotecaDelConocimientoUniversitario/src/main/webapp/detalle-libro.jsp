<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*" %>
<%@ include file="config/conexion.jsp" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detalle del Libro - Biblioteca Universitaria</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        .book-cover {
            width: 300px;
            height: 400px;
            object-fit: cover;
            border: 1px solid #ccc;
        }
        .separator {
            margin: 40px 0;
            height: 2px;
            background-color: #e0e0e0;
        }
    </style>
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
            <%
                if (session.getAttribute("usuario_id") != null) {
                    String tipoUsuario = (String) session.getAttribute("tipo_usuario");
                    if ("bibliotecario".equals(tipoUsuario)) {
                        out.println("<a href='panel-bibliotecario.jsp' class='nav-link'>Panel Bibliotecario</a>");
                    } else {
                        out.println("<a href='panel-usuario.jsp' class='nav-link'>Mi Panel</a>");
                    }
                } else {
                    out.println("<a href='login.html' class='nav-link'>Login</a>");
                }
            %>
        </nav>
    </div>
</header>

<main class="main">
    <div class="container">
        <div class="breadcrumb">
            <a href="catalogo-libros.jsp">Catálogo</a> > Detalle del Libro
        </div>

        <%
            String libroId = request.getParameter("id");
            if (libroId != null) {
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;

                try {
                    conn = getConnection();
                    String sql = "SELECT l.*, a.au_nombre, a.au_apellido, s.sed_nombre, e.edi_nombre, " +
                                 "i.cantidad_libros as cantidad, l.url_portada, l.lib_descripcion " +
                                 "FROM libro l " +
                                 "JOIN autor a ON l.cod_autor = a.cod_autor " +
                                 "JOIN sede s ON l.cod_sede = s.cod_sede " +
                                 "JOIN editorial e ON l.cod_editorial = e.cod_editorial " +
                                 "LEFT JOIN inventario i ON l.cod_libro = i.cod_libro " +
                                 "WHERE l.cod_libro = ?";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setInt(1, Integer.parseInt(libroId));
                    rs = pstmt.executeQuery();

                    if (rs.next()) {
                        String urlPortada = rs.getString("url_portada");
                        if (urlPortada == null || urlPortada.trim().isEmpty()) {
                            urlPortada = "/placeholder.svg?height=400&width=300";
                        }

                        String descripcion = rs.getString("lib_descripcion");
                        if (descripcion == null || descripcion.trim().isEmpty()) {
                            descripcion = "Descripción no disponible para este libro.";
                        }

                        out.println("<div class='book-detail'>");
                        out.println("<div class='book-image-section'>");
                        out.println("<img src='" + urlPortada + "' alt='" + rs.getString("lib_nombre") + "' class='book-cover'>");
                        out.println("</div>");

                        out.println("<div class='book-info-section'>");
                        out.println("<h1>" + rs.getString("lib_nombre") + "</h1>");
                        out.println("<h2>" + rs.getString("au_nombre") + " " + rs.getString("au_apellido") + "</h2>");

                        out.println("<div class='book-meta'>");
                        out.println("<div class='meta-item'><strong>ISBN:</strong> " + rs.getString("lib_isbn") + "</div>");
                        out.println("<div class='meta-item'><strong>Editorial:</strong> " + rs.getString("edi_nombre") + "</div>");
                        out.println("<div class='meta-item'><strong>Año de Publicación:</strong> " + rs.getInt("lib_año_publicacion") + "</div>");
                        out.println("<div class='meta-item'><strong>Edición:</strong> " + rs.getInt("lib_edicion") + "</div>");
                        out.println("<div class='meta-item'><strong>Sede:</strong> " + rs.getString("sed_nombre") + "</div>");
                        out.println("</div>");

                        out.println("<div class='book-description'>");
                        out.println("<h3>Descripción</h3>");
                        out.println("<p>" + descripcion + "</p>");
                        out.println("</div>");

                        out.println("<div class='availability-section'>");
                        out.println("<h3>Disponibilidad</h3>");
                        out.println("<div class='availability-item'>");
                        out.println("<div class='sede-name'>" + rs.getString("sed_nombre") + "</div>");
                        out.println("<div class='stock-info'>");

                        int cantidad = rs.getInt("cantidad");
                        if (cantidad > 0) {
                            out.println("<span class='available'>" + cantidad + " disponibles</span>");
                        } else {
                            out.println("<span class='unavailable'>No disponible</span>");
                        }

                        out.println("</div>");

                        if (session.getAttribute("usuario_id") != null && "estudiante".equals(session.getAttribute("tipo_usuario")) && cantidad > 0) {
                            out.println("<a href='reservar-libro.jsp?libro_id=" + rs.getInt("cod_libro") + "' class='btn btn-primary'>Reservar</a>");
                        } else if (cantidad == 0) {
                            out.println("<button class='btn btn-disabled' disabled>No Disponible</button>");
                        } else if (session.getAttribute("usuario_id") == null) {
                            out.println("<a href='login.html' class='btn btn-primary'>Iniciar Sesión para Reservar</a>");
                        }

                        out.println("</div>");
                        out.println("</div>");
                        out.println("</div>");
                        out.println("</div>");

                        out.println("<div class='separator'></div>");

                        out.println("<section class='related-books'>");
                        out.println("<h3>Otros libros del mismo autor</h3>");
                        out.println("<div class='books-grid'>");

                        String sqlRelated = "SELECT l.*, a.au_nombre, a.au_apellido, i.cantidad_libros, l.url_portada " +
                                            "FROM libro l " +
                                            "JOIN autor a ON l.cod_autor = a.cod_autor " +
                                            "LEFT JOIN inventario i ON l.cod_libro = i.cod_libro " +
                                            "WHERE l.cod_autor = ? AND l.cod_libro != ? AND i.cantidad_libros > 0 LIMIT 4";
                        PreparedStatement pstmtRelated = conn.prepareStatement(sqlRelated);
                        pstmtRelated.setInt(1, rs.getInt("cod_autor"));
                        pstmtRelated.setInt(2, Integer.parseInt(libroId));
                        ResultSet rsRelated = pstmtRelated.executeQuery();

                        while (rsRelated.next()) {
                            String urlPortadaRelated = rsRelated.getString("url_portada");
                            if (urlPortadaRelated == null || urlPortadaRelated.trim().isEmpty()) {
                                urlPortadaRelated = "/placeholder.svg?height=400&width=300";
                            }

                            out.println("<div class='book-card'>");
                            out.println("<img src='" + urlPortadaRelated + "' alt='" + rsRelated.getString("lib_nombre") + "' class='book-cover'>");
                            out.println("<div class='book-info'>");
                            out.println("<h4>" + rsRelated.getString("lib_nombre") + "</h4>");
                            out.println("<p>" + rsRelated.getString("au_nombre") + " " + rsRelated.getString("au_apellido") + "</p>");
                            out.println("<div class='book-meta'>");
                            out.println("<span>ISBN: " + rsRelated.getString("lib_isbn") + "</span>");
                            out.println("<span class='stock'>" + rsRelated.getInt("cantidad_libros") + " disponibles</span>");
                            out.println("</div>");
                            out.println("<a href='detalle-libro.jsp?id=" + rsRelated.getInt("cod_libro") + "' class='btn btn-outline'>Ver Detalle</a>");
                            out.println("</div>");
                            out.println("</div>");
                        }

                        rsRelated.close();
                        pstmtRelated.close();

                        out.println("</div>");
                        out.println("</section>");

                    } else {
                        out.println("<div class='no-results'><h3>Libro no encontrado</h3><a href='catalogo-libros.jsp' class='btn'>Volver</a></div>");
                    }
                } catch (Exception e) {
                    out.println("<div class='no-results'><h3>Error</h3><p>" + e.getMessage() + "</p></div>");
                } finally {
                    closeResources(conn, pstmt, rs);
                }
            } else {
                out.println("<div class='no-results'><h3>Libro no especificado</h3><a href='catalogo-libros.jsp' class='btn'>Volver</a></div>");
            }
        %>
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