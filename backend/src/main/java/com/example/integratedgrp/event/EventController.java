package com.example.integratedgrp.event;

import java.net.URI;
import java.util.List;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

@RestController
@RequestMapping("/api")
public class EventController {
    private final EventService eventService;

    public EventController(EventService eventService) {
        this.eventService = eventService;
    }

    @GetMapping("/events")
    public List<EventResponse> listEvents() {
        return eventService.listEvents();
    }

    @PostMapping("/events")
    public ResponseEntity<EventResponse> createEvent(@Valid @RequestBody CreateEventRequest request) {
        EventResponse event = eventService.createEvent(request);
        URI location = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{eventId}")
                .buildAndExpand(event.id())
                .toUri();
        return ResponseEntity.created(location).body(event);
    }

    @PostMapping("/events/{eventId}/applications")
    public ResponseEntity<ApplicationResponse> apply(
            @PathVariable Long eventId, @Valid @RequestBody ApplyRequest request) {
        ApplicationResponse application = eventService.apply(eventId, request);
        URI location = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{applicationId}")
                .buildAndExpand(application.id())
                .toUri();
        return ResponseEntity.created(location).body(application);
    }

    @GetMapping("/events/{eventId}/applications")
    public List<ApplicationResponse> listApplications(@PathVariable Long eventId) {
        return eventService.listApplications(eventId);
    }
}

record CreateEventRequest(
        @NotBlank @Size(max = 120) String name,
        @NotBlank @Size(max = 100) String duration,
        @NotBlank @Size(max = 4000) String description) {}

record ApplyRequest(
        @NotBlank @Size(max = 120) String applicantName,
        @NotBlank @Size(max = 2000) String reason) {}

record EventResponse(
        Long id,
        String name,
        String duration,
        String description,
        int applicantCount,
        java.time.Instant createdAt) {}

record ApplicationResponse(
        Long id,
        Long eventId,
        String applicantName,
        String reason,
        java.time.Instant appliedAt) {}