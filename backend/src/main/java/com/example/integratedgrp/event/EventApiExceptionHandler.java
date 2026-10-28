package com.example.integratedgrp.event;

import java.time.Instant;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class EventApiExceptionHandler {
    @ExceptionHandler(EventNotFoundException.class)
    public ResponseEntity<ApiError> handleNotFound(EventNotFoundException exception) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(new ApiError("EVENT_NOT_FOUND", exception.getMessage(), Instant.now()));
    }

    @ExceptionHandler(DuplicateApplicationException.class)
    public ResponseEntity<ApiError> handleDuplicate(DuplicateApplicationException exception) {
        return ResponseEntity.status(HttpStatus.CONFLICT)
                .body(new ApiError("ALREADY_APPLIED", exception.getMessage(), Instant.now()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiError> handleValidation(MethodArgumentNotValidException exception) {
        String message = exception.getBindingResult().getFieldErrors().stream()
                .findFirst()
                .map(error -> error.getField() + " " + error.getDefaultMessage())
                .orElse("Request validation failed.");
        return ResponseEntity.badRequest()
                .body(new ApiError("INVALID_REQUEST", message, Instant.now()));
    }

    public record ApiError(String code, String message, Instant timestamp) {}
}

class EventNotFoundException extends RuntimeException {
    EventNotFoundException(Long eventId) {
        super("Event " + eventId + " was not found.");
    }
}

class DuplicateApplicationException extends RuntimeException {
    DuplicateApplicationException() {
        super("This name has already applied to the event.");
    }
}