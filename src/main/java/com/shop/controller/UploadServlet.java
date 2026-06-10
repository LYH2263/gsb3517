package com.shop.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@WebServlet("/admin/upload")
@MultipartConfig(
    maxFileSize = 5 * 1024 * 1024,      // 5MB
    maxRequestSize = 10 * 1024 * 1024,   // 10MB
    fileSizeThreshold = 256 * 1024       // 256KB
)
public class UploadServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "assets/images/products";

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        try {
            Part filePart = req.getPart("file");
            if (filePart == null || filePart.getSize() == 0) {
                out.print("{\"success\":false,\"message\":\"请选择图片文件\"}");
                return;
            }

            String contentType = filePart.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                out.print("{\"success\":false,\"message\":\"只允许上传图片文件\"}");
                return;
            }

            String originalName = getFileName(filePart);
            String ext = "";
            if (originalName != null && originalName.contains(".")) {
                ext = originalName.substring(originalName.lastIndexOf(".")).toLowerCase();
            }
            if (ext.isEmpty()) {
                ext = contentType.equals("image/png") ? ".png"
                    : contentType.equals("image/gif") ? ".gif"
                    : contentType.equals("image/webp") ? ".webp"
                    : ".jpg";
            }

            String newFileName = UUID.randomUUID().toString().replace("-", "").substring(0, 16) + ext;
            String uploadPath = req.getServletContext().getRealPath("/" + UPLOAD_DIR);

            Path dir = Paths.get(uploadPath);
            if (!Files.exists(dir)) {
                Files.createDirectories(dir);
            }

            Path filePath = dir.resolve(newFileName);
            filePart.write(filePath.toString());

            String imageUrl = "/" + UPLOAD_DIR + "/" + newFileName;
            out.print("{\"success\":true,\"url\":\"" + imageUrl + "\"}");

        } catch (IllegalStateException e) {
            out.print("{\"success\":false,\"message\":\"文件大小超过限制(最大5MB)\"}");
        } catch (Exception e) {
            out.print("{\"success\":false,\"message\":\"上传失败: " + e.getMessage().replace("\"", "'") + "\"}");
        }
    }

    private String getFileName(Part part) {
        String header = part.getHeader("content-disposition");
        if (header != null) {
            for (String token : header.split(";")) {
                if (token.trim().startsWith("filename")) {
                    String name = token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
                    // Handle IE full path
                    int idx = name.lastIndexOf('/');
                    if (idx < 0) idx = name.lastIndexOf('\\');
                    return idx >= 0 ? name.substring(idx + 1) : name;
                }
            }
        }
        return null;
    }
}
