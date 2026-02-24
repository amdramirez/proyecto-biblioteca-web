<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*" %>
<%@ include file="../config/conexion.jsp" %>
<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        conn = getConnection();
        String sql = "SELECT l.cod_libro, l.lib_nombre, l.lib_isbn, l.url_portada, " +
                   "CONCAT(a.au_nombre, ' ', a.au_apellido) as autor, " +
                   "s.sed_nombre, i.cantidad_libros " +
                   "FROM libro l " +
                   "JOIN autor a ON l.cod_autor = a.cod_autor " +
                   "JOIN sede s ON l.cod_sede = s.cod_sede " +
                   "LEFT JOIN inventario i ON l.cod_libro = i.cod_libro " +
                   "WHERE i.cantidad_libros > 0 " +
                   "ORDER BY i.cantidad_libros DESC " +
                   "LIMIT 6";
        
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        
        while (rs.next()) {
            String urlPortada = rs.getString("url_portada");
            if (urlPortada == null || urlPortada.trim().isEmpty()) {
                urlPortada = "/placeholder.svg?height=200&width=150";
            }
            
            out.println("<div class='book-card'>");
            out.println("<img src='" + urlPortada + "' alt='" + rs.getString("lib_nombre") + "' onerror=\"this.src='/placeholder.svg?height=200&width=150'\">");
            out.println("<div class='book-info'>");
            out.println("<h4>" + rs.getString("lib_nombre") + "</h4>");
            out.println("<p>" + rs.getString("autor") + "</p>");
            out.println("<div class='book-meta'>");
            out.println("<span>ISBN: " + rs.getString("lib_isbn") + "</span>");
            out.println("<span class='stock'>" + rs.getInt("cantidad_libros") + " disponibles</span>");
            out.println("<span>Sede: " + rs.getString("sed_nombre") + "</span>");
            out.println("</div>");
            out.println("<a href='detalle-libro.jsp?id=" + rs.getInt("cod_libro") + "' class='btn btn-outline'>Ver Detalle</a>");
            out.println("</div>");
            out.println("</div>");
        }
        
    } catch (Exception e) {
        out.println("<p>Error al cargar libros destacados: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        closeResources(conn, pstmt, rs);
    }
%>
