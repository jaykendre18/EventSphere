package com.example.integratedgrp.event;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

public interface EventApplicationRepository extends JpaRepository<EventApplicationEntity, Long> {
    List<EventApplicationEntity> findAllByEvent_IdOrderByAppliedAtDesc(Long eventId);

    boolean existsByEvent_IdAndApplicantNameIgnoreCase(Long eventId, String applicantName);
}