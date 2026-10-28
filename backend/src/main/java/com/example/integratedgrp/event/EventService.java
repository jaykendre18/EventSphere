package com.example.integratedgrp.event;

import java.util.List;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class EventService {
    private final EventRepository eventRepository;
    private final EventApplicationRepository applicationRepository;

    public EventService(
            EventRepository eventRepository,
            EventApplicationRepository applicationRepository) {
        this.eventRepository = eventRepository;
        this.applicationRepository = applicationRepository;
    }

    @Transactional(readOnly = true)
    public List<EventResponse> listEvents() {
        return eventRepository.findAll(Sort.by(Sort.Direction.DESC, "createdAt")).stream()
                .map(this::toEventResponse)
                .toList();
    }

    @Transactional
    public EventResponse createEvent(CreateEventRequest request) {
        EventEntity event = new EventEntity(
                request.name().trim(), request.duration().trim(), request.description().trim());
        return toEventResponse(eventRepository.save(event));
    }

    @Transactional
    public ApplicationResponse apply(Long eventId, ApplyRequest request) {
        EventEntity event = findEvent(eventId);
        String applicantName = request.applicantName().trim();
        if (applicationRepository.existsByEvent_IdAndApplicantNameIgnoreCase(eventId, applicantName)) {
            throw new DuplicateApplicationException();
        }

        try {
            EventApplicationEntity application = applicationRepository.saveAndFlush(
                    new EventApplicationEntity(event, applicantName, request.reason().trim()));
            return toApplicationResponse(application);
        } catch (DataIntegrityViolationException exception) {
            throw new DuplicateApplicationException();
        }
    }

    @Transactional(readOnly = true)
    public List<ApplicationResponse> listApplications(Long eventId) {
        findEvent(eventId);
        return applicationRepository.findAllByEvent_IdOrderByAppliedAtDesc(eventId).stream()
                .map(this::toApplicationResponse)
                .toList();
    }

    private EventEntity findEvent(Long eventId) {
        return eventRepository.findById(eventId).orElseThrow(() -> new EventNotFoundException(eventId));
    }

    private EventResponse toEventResponse(EventEntity event) {
        return new EventResponse(
                event.getId(),
                event.getName(),
                event.getDuration(),
                event.getDescription(),
                event.getApplications().size(),
                event.getCreatedAt());
    }

    private ApplicationResponse toApplicationResponse(EventApplicationEntity application) {
        return new ApplicationResponse(
                application.getId(),
                application.getEvent().getId(),
                application.getApplicantName(),
                application.getReason(),
                application.getAppliedAt());
    }
}